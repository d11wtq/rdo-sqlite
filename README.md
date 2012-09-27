# RDO SQLite3 Driver

This is the SQLite3 driver for [RDO—Ruby Data Objects]
(https://github.com/d11wtq/rdo).

Refer to the RDO project [README](https://github.com/d11wtq/rdo) for usage
information.

## Installation

Via rubygems:

    $ gem install rdo-sqlite

Or add the following line to your application's Gemfile:

    gem "rdo-sqlite"

And install with Bundler:

    $ bundle install

## Usage

The registered URI schemes are sqlite: and sqlite3:

``` ruby
require "rdo"
require "rdo-sqlite"

# use an in-memory database :memory:
db = RDO.open("sqlite::memory:")

# use a temporary file for the database (automatically deleted once closed)
db = RDO.open("sqlite:")

# use a relative path to a database (will be created if it doesn't exist)
db = RDO.open("sqlite:some/path/to/your.db")

# use an absolute path to a database
db = RDO.open("sqlite:/absolute/path/to/your.db")
```

## Type casting and bind parameters

SQLite, being a very basic database only has limited type support. Without
going into the whole discussion about SQLite's "type affinity" and how it
will effectively store anything in any column declared as any type, know that
the only internal types it actually stores are:

  - NULL, which converts to nil in Ruby
  - TEXT, which converts to a UTF-8 encoded String in Ruby
  - INTEGER, which converts to a Fixnum in Ruby
  - REAL, which converts to a Float in Ruby
  - BLOB, which converts to a binary String in Ruby

If you have fields storing date strings etc, they are just Text, so are
returned as Strings, which you need to convert by hand. SQLite has no actual
DATE type, even if its date functions operate on strings formatted correctly.

### Boolean types

Because defining fields as BOOLEAN and storing integer 0 or 1 in them is
common, rdo-sqlite will convert boolean bind parameters to 0 or 1. If you
actually want to store the String 'true' or 'false', you will need to
convert it to a String first.

### Character encoding

SQLite does not allow the encoding of an existing database to be changed. It
only supports two encodings: UTF-8 and UTF-16. rdo-sqlite currently just
assumes UTF-8 encoding.

## Contributing

If you find any bugs, please send a pull request if you think you can
fix it, or file in an issue in the issue tracker.

When sending pull requests, please use topic branches—don't send a pull
request from the master branch of your fork, as that may change
unintentionally.

Contributors will be credited in this README.

## Copyright & Licensing

Written by Chris Corbyn.

Licensed under the MIT license. See the LICENSE file for full details.
