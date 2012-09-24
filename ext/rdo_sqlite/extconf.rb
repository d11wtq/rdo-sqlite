# encoding: utf-8

require "mkmf"

if ENV["CC"]
  RbConfig::MAKEFILE_CONFIG["CC"] = ENV["CC"]
end

def have_build_env
  [
    have_library("sqlite3"),
    have_header("sqlite3.h")
  ].all?
end

dir_config("sqlite")

unless have_build_env
  puts "Unable to find sqlite3 libraries and headers. Not building."
  exit(1)
end

create_makefile("rdo_sqlite/rdo_sqlite")
