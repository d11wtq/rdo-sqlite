##
# RDO SQLite3 driver.
# Copyright © 2012 Chris Corbyn.
#
# See LICENSE file for details.
##

module RDO
  module SQLite
    # Main Driver class to hook into sqlite3 API
    class Driver < RDO::Driver
      def execute(stmt, *args)
        prepare(stmt).execute(*args)
      end

      private

      def filename
        options[:path].to_s
      end
    end
  end
end
