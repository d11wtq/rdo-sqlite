##
# RDO SQLite3 driver.
# Copyright © 2012 Chris Corbyn.
#
# See LICENSE file for details.
##

require "rdo"
require "rdo/sqlite/version"
require "rdo/sqlite/driver"
require "rdo_sqlite/rdo_sqlite" # c extension

# Register driver with RDO
%w[sqlite sqlite3].each do |name|
  RDO::Connection.register_driver(name, RDO::SQLite::Driver)
end
