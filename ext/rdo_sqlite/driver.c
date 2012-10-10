/*
 * RDO SQLite3 Driver.
 * Copyright © 2012 Chris Corbyn.
 *
 * See LICENSE file for details.
 */

#include <stdio.h>
#include <stdlib.h>
#include "driver.h"
#include "macros.h"
#include "statements.h"

/** Free memory associated with the driver during GC */
static void rdo_sqlite_driver_free(RDOSQLiteDriver * driver) {
  sqlite3_close(driver->db);
  free(driver);
}

/** Wrap the RDOSQLiteDriver struct with the new instance */
static VALUE rdo_sqlite_driver_allocate(VALUE klass) {
  RDOSQLiteDriver * driver = malloc(sizeof(RDOSQLiteDriver));
  driver->db      = NULL;
  driver->is_open = 0;

  return Data_Wrap_Struct(klass, 0, rdo_sqlite_driver_free, driver);
}

/** Opens a database */
static VALUE rdo_sqlite_driver_open(VALUE self) {
  RDOSQLiteDriver * driver;
  Data_Get_Struct(self, RDOSQLiteDriver, driver);

  if (driver->is_open) {
    return Qtrue;
  }

  if (sqlite3_open_v2(
        RSTRING_PTR(rb_funcall(self, rb_intern("filename"), 0)),
        &(driver->db),
        SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL) != SQLITE_OK) {
    RDO_ERROR("SQLite3 database open failed: %s", sqlite3_errmsg(driver->db));
  } else {
    driver->is_open = 1;
  }

  return Qtrue;
}

/** Checks if the database file is open */
static VALUE rdo_sqlite_driver_open_p(VALUE self) {
  RDOSQLiteDriver * driver;
  Data_Get_Struct(self, RDOSQLiteDriver, driver);
  return driver->is_open ? Qtrue : Qfalse;
}

/** Close the database and free memory */
static VALUE rdo_sqlite_driver_close(VALUE self) {
  RDOSQLiteDriver * driver;
  Data_Get_Struct(self, RDOSQLiteDriver, driver);

  sqlite3_close(driver->db);
  driver->db      = NULL;
  driver->is_open = 0;

  return Qtrue;
}

/** Create a new prepared statement for cmd */
static VALUE rdo_sqlite_driver_prepare(VALUE self, VALUE cmd) {
  return rdo_sqlite_statement_executor_new(self, cmd);
}

/** Quote a string literal for interpolation into a statement */
static VALUE rdo_sqlite_driver_quote(VALUE self, VALUE str) {
  Check_Type(str, T_STRING);
  char * quoted = sqlite3_mprintf("%q", RSTRING_PTR(str));
  VALUE new_str = rb_str_new2(quoted);
  sqlite3_free(quoted);
  return new_str;
}

/** Initialize driver class */
void Init_rdo_sqlite_driver(void) {
  rb_require("rdo");
  rb_require("rdo/sqlite/driver");

  VALUE cSQLiteDriver = rb_path2class("RDO::SQLite::Driver");

  rb_define_alloc_func(cSQLiteDriver, rdo_sqlite_driver_allocate);

  rb_define_method(cSQLiteDriver, "open", rdo_sqlite_driver_open, 0);
  rb_define_method(cSQLiteDriver, "open?", rdo_sqlite_driver_open_p, 0);
  rb_define_method(cSQLiteDriver, "close", rdo_sqlite_driver_close, 0);
  rb_define_method(cSQLiteDriver, "prepare", rdo_sqlite_driver_prepare, 1);
  rb_define_method(cSQLiteDriver, "quote", rdo_sqlite_driver_quote, 1);

  Init_rdo_sqlite_statements();
}
