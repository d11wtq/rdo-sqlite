/*
 * RDO SQLite3 Driver.
 * Copyright © 2012 Chris Corbyn.
 *
 * See LICENSE file for details.
 */

#include <stdio.h>
#include <stdlib.h>
#include "statements.h"
#include "driver.h"
#include "macros.h"

/** Sruct wrapped by class RDO::SQLite::StatementExecutor */
typedef struct {
  RDOSQLiteDriver * driver;
  char            * cmd;
  sqlite3_stmt    * stmt;
} RDOSQLiteStatementExecutor;

/** RDO::SQLite::StatementExecutor class */
VALUE rdo_sqlite_cStatementExecutor;

/** Free memory associated with the statement during GC */
static void rdo_sqlite_statement_executor_free(RDOSQLiteStatementExecutor * executor) {
  sqlite3_finalize(executor->stmt);
  free(executor);
}

/** Check if the 'tail' of a query points to something other than a comment */
static int rdo_sqlite_inert_p(char * s) {
  int  inslcmt = 0;
  int  inmlcmt = 0;

  for (; *s; ++s) {
    switch (*s) {
      case ' ':
      case '\t':
        break;

      case '\r':
      case '\n':
        inslcmt = 0;
        break;

      case '/':
        if (!inslcmt && *(s + 1) == '*') {
          inmlcmt = 1;
          ++s;
        } else if (!inslcmt && !inmlcmt) {
          return 0;
        }
        break;

      case '*':
        if (inmlcmt && *(s + 1) == '/') {
          inmlcmt = 0;
          ++s;
        } else if (!inslcmt && !inmlcmt) {
          return 0;
        }
        break;

      case '-':
        if (!inmlcmt && *(s + 1) == '-') {
          inslcmt = 1;
          ++s;
        } else if (!inslcmt && !inmlcmt) {
          return 0;
        }
        break;

      default:
        if (!inslcmt && !inmlcmt) {
          return 0;
        }
    }
  }

  return 1;
}

/** Create a new statement executor for the given command */
VALUE rdo_sqlite_statement_executor_new(VALUE driver, VALUE cmd) {
  Check_Type(cmd, T_STRING);

  RDOSQLiteStatementExecutor * executor =
    malloc(sizeof(RDOSQLiteStatementExecutor));

  Data_Get_Struct(driver, RDOSQLiteDriver, executor->driver);
  executor->cmd    = strdup(RSTRING_PTR(cmd));
  executor->stmt   = NULL;

  VALUE self = Data_Wrap_Struct(rdo_sqlite_cStatementExecutor, 0,
      rdo_sqlite_statement_executor_free, executor);

  rb_obj_call_init(self, 1, &driver);

  return self;
}

/** Initialize the statement (prepare it) */
static VALUE rdo_sqlite_statement_executor_initialize(VALUE self, VALUE driver) {
  rb_iv_set(self, "driver", driver); // GC safety
  RDOSQLiteStatementExecutor * executor;
  Data_Get_Struct(self, RDOSQLiteStatementExecutor, executor);

  if (!(executor->driver->is_open)) {
    RDO_ERROR("Cannot execute prepare statement: database is not open");
  }

  const char * tail;

  int status = sqlite3_prepare_v2(executor->driver->db,
      executor->cmd,
      (int) strlen(executor->cmd) + 1,
      &(executor->stmt),
      &tail);

  if ((status != SQLITE_OK) || sqlite3_errcode(executor->driver->db)) {
    RDO_ERROR("Failed to prepare statement: %s",
        sqlite3_errmsg(executor->driver->db));
  }

  if (!rdo_sqlite_inert_p((char *) tail)) {
    rb_raise(rb_eArgError, "Only one statement can be executed at a time");
  }

  return self;
}

/** Get the command this statement will execute */
static VALUE rdo_sqlite_statement_executor_command(VALUE self) {
  RDOSQLiteStatementExecutor * executor;
  Data_Get_Struct(self, RDOSQLiteStatementExecutor, executor);
  return rb_str_new2(executor->cmd);
}

/** Fetch the value from the given column in the result and convert to a Ruby type */
static VALUE rdo_sqlite_cast_value(sqlite3_stmt * stmt, int col) {
  switch (sqlite3_column_type(stmt, col)) {
    case SQLITE_NULL:
      return Qnil;

    case SQLITE_INTEGER:
      return LL2NUM(sqlite3_column_int64(stmt, col));

    case SQLITE_FLOAT:
      return DBL2NUM(sqlite3_column_double(stmt, col));

    case SQLITE_TEXT:
      return RDO_STRING((const char *) sqlite3_column_text(stmt, col),
          sqlite3_column_bytes(stmt, col), 1);

    case SQLITE_BLOB:
      return RDO_BINARY_STRING((const char *) sqlite3_column_blob(stmt, col),
          sqlite3_column_bytes(stmt, col));

    default:
      return RDO_BINARY_STRING((const char *) sqlite3_column_text(stmt, col),
          sqlite3_column_bytes(stmt, col));
  }
}

/** Extract useful result information from the db and the statement */
static VALUE rdo_sqlite_result_info(sqlite3 * db, sqlite3_stmt * stmt) {
  VALUE info = rb_hash_new();
  rb_hash_aset(info, ID2SYM(rb_intern("insert_id")),
      LL2NUM(sqlite3_last_insert_rowid(db)));
  rb_hash_aset(info, ID2SYM(rb_intern("affected_rows")),
      LL2NUM(sqlite3_changes(db)));
  return info;
}

/** Bind all input values to the statement */
static void rdo_sqlite_statement_bind_args(sqlite3_stmt * stmt, int argc, VALUE * args) {
  if (sqlite3_bind_parameter_count(stmt) != argc) {
    rb_raise(rb_eArgError,
        "Bind parameter count mismatch: wanted %i, got %i",
        sqlite3_bind_parameter_count(stmt),
        argc);
  }

  VALUE v;
  int   i = 0;

  for (; i < argc; ++i) {
    v = args[i];

    if (v == Qnil) {
      sqlite3_bind_null(stmt, i);
    } else {
      if (v == Qtrue)          v = INT2NUM(1);
      if (v == Qfalse)         v = INT2NUM(0);

      if ((rb_funcall(v, rb_intern("kind_of?"), 1, rb_cTime) == Qtrue)
          || rb_funcall(v, rb_intern("kind_of?"), 1, rb_path2class("DateTime"))) {
        v = rb_funcall(v, rb_intern("strftime"), 1, rb_str_new2("%F %T"));
      }

      if (TYPE(v) != T_STRING) v = RDO_OBJ_TO_S(v);

      sqlite3_bind_text(stmt, i + 1,
          RSTRING_PTR(v), (int) RSTRING_LEN(v), NULL);
    }
  }
}

/** Iterate over all rows in the result and return an Array */
static VALUE rdo_sqlite_statement_extract_tuples(sqlite3 * db, sqlite3_stmt * stmt) {
  int   status;
  int   col     = 0;
  int   ncols   = 0;
  VALUE hash;
  VALUE tuples  = rb_ary_new();

  while ((status = sqlite3_step(stmt)) == SQLITE_ROW) {
    hash  = rb_hash_new();
    ncols = sqlite3_column_count(stmt);

    for (col = 0; col < ncols; ++col) {
      rb_hash_aset(hash,
          ID2SYM(rb_intern(sqlite3_column_name(stmt, col))),
          rdo_sqlite_cast_value(stmt, col));
    }

    rb_ary_push(tuples, hash);
  }

  if (status != SQLITE_DONE) {
    RDO_ERROR("Failed to execute statement: %s", sqlite3_errmsg(db));
  }

  return tuples;
}

/** Execute the statement with the given bind parameters and return a Result */
static VALUE rdo_sqlite_statement_executor_execute(int argc, VALUE * args, VALUE self) {
  RDOSQLiteStatementExecutor * executor;
  Data_Get_Struct(self, RDOSQLiteStatementExecutor, executor);

  if (!(executor->driver->is_open)) {
    RDO_ERROR("Cannot execute execute statement: database is not open");
  }

  rdo_sqlite_statement_bind_args(executor->stmt, argc, args);

  VALUE tuples = rdo_sqlite_statement_extract_tuples(executor->driver->db, executor->stmt);
  VALUE info   = rdo_sqlite_result_info(executor->driver->db, executor->stmt);
  sqlite3_reset(executor->stmt);

  return RDO_RESULT(tuples, info);
}

/** Initialize the statements framework */
void Init_rdo_sqlite_statements(void) {
  rb_require("date");

  VALUE mSQLite = rb_path2class("RDO::SQLite");
  rdo_sqlite_cStatementExecutor = rb_define_class_under(
      mSQLite, "StatementExecutor", rb_cObject);

  rb_define_method(rdo_sqlite_cStatementExecutor,
      "initialize", rdo_sqlite_statement_executor_initialize, 1);
  rb_define_method(rdo_sqlite_cStatementExecutor,
      "command", rdo_sqlite_statement_executor_command, 0);
  rb_define_method(rdo_sqlite_cStatementExecutor,
      "execute", rdo_sqlite_statement_executor_execute, -1);
}
