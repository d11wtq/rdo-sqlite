/*
 * RDO SQLite3 Driver.
 * Copyright © 2012 Chris Corbyn.
 *
 * See LICENSE file for details.
 */

#include <ruby.h>
#include <sqlite3.h>

/** Struct wrapped by RDO::SQLite::Driver class */
typedef struct {
  sqlite3 * db;
  int       is_open;
} RDOSQLiteDriver;

/** Called during extension initialization to create the Driver class */
void Init_rdo_sqlite_driver(void);
