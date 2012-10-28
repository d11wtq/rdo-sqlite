# RDO SQLite3 Driver

This is the SQLite3 driver for [RDO—Ruby Data Objects]
(https://github.com/d11wtq/rdo).

[![Build Status](https://secure.travis-ci.org/d11wtq/rdo-sqlite.png?branch=master)](http://travis-ci.org/d11wtq/rdo-sqlite)

Refer to the [RDO project README](https://github.com/d11wtq/rdo) for full
usage information.

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
require "rdo-sqlite"

# use an in-memory database :memory:
db = RDO.open("sqlite::memory:")

# use a temporary file for the database (automatically deleted once closed)
db = RDO.open("sqlite:")

# use a relative path to a database (will be created if it doesn't exist)
db = RDO.open("sqlite:some/path/to/your.db")

# use an absolute path to a database
db = RDO.open("sqlite:/absolute/path/to/your.db")

# open in read-only mode
db = RDO.open("sqlite:/path/to/your.db?mode=readonly")
```

## Type support

SQLite has extremely limited type support. In fact, it only supports five
types. It allows other types to be specified as column types, but they will
be one of the core five types. It also allows storing any value of any type
in any column, regardless of what the column type is. You can read about that
[here](http://www.sqlite.org/datatype3.html).

The five data types are mapped as below:

<table>
  <thead>
    <tr>
      <th>SQLite Type</th>
      <th>Ruby Type</th>
      <th>Notes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>NULL</th>
      <td>NilClass</td>
      <td></td>
    </tr>
    <tr>
      <th>TEXT</th>
      <td>String</td>
      <td>The encoding is always UTF-8</td>
    </tr>
    <tr>
      <th>INTEGER</th>
      <td>Fixnum</td>
      <td></td>
    </tr>
    <tr>
      <th>REAL</th>
      <td>Float</td>
      <td></td>
    </tr>
    <tr>
      <th>BLOB</th>
      <td>String</td>
      <td>The encoding is always ASCII-8BIT/BINARY</td>
    </tr>
  </tbody>
</table>

### Boolean types

Because defining fields as BOOLEAN and storing integer 0 or 1 in them is
common, rdo-sqlite will convert boolean bind parameters to 0 or 1.

### Character encoding

SQLite does not allow the encoding of an existing database to be changed. It
only supports two encodings for new databases: UTF-8 and UTF-16. rdo-sqlite
currently just assumes UTF-8 encoding. Support for UTF-16 is planned.

## Contributing

If you find any bugs, please send a pull request if you think you can
fix it, or file in an issue in the issue tracker.

When sending pull requests, please use topic branches—don't send a pull
request from the master branch of your fork.

Contributors will be credited in this README.

## Copyright & Licensing

Written by Chris Corbyn.

Licensed under the MIT license. See the LICENSE file for full details.
