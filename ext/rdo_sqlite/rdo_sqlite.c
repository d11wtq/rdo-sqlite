/*
 * RDO SQLite3 Driver.
 * Copyright © 2012 Chris Corbyn.
 *
 * See LICENSE file for details.
 */

#include <ruby.h>
#include "driver.h"

/** Extension initializer */
void Init_rdo_sqlite(void) {
  rb_require("rdo");
  Init_rdo_sqlite_driver();
}
