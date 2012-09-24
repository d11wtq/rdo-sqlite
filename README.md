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
