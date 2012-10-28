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
      # Execute a single statement.
      #
      # This method delegates to #prepare, then executes.
      #
      # @param [String] stmt
      #   the statement to execute, with optional bind markers
      #
      # @param [Object...] *args
      #   bind parameters
      #
      # @return [RDO::Result]
      #   the result of executing the statement
      def execute(stmt, *args)
        prepare(stmt).execute(*args)
      end

      # Predicte check to see if this is a read-only database.
      #
      # @return [Boolean]
      #   true if ?mode=ro
      def readonly?
        %w[ro readonly].include?(options[:mode])
      end

      private

      def filename
        options[:path].to_s
      end
    end
  end
end
