/*
 * RDO SQLite3 Driver.
 * Copyright © 2012 Chris Corbyn.
 *
 * See LICENSE file for details.
 */

#include <ruby.h>
#include <sqlite3.h>

/** Create a new prepared statement executor for the given command */
VALUE rdo_sqlite_statement_executor_new(VALUE driver, VALUE cmd);

/** Initialize the prepared statements class */
void Init_rdo_sqlite_statements(void);
