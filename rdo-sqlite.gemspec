# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rdo/sqlite/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["d11wtq"]
  gem.email         = ["chris@w3style.co.uk"]
  gem.description   = "Provides access to SQLite3 using the RDO interface"
  gem.summary       = "SQLite3 Driver for RDO"
  gem.homepage      = "https://github.com/d11wtq/rdo-sqlite"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rdo-sqlite"
  gem.require_paths = ["lib"]
  gem.version       = RDO::SQLite::VERSION
  gem.extensions    = ["ext/rdo_sqlite/extconf.rb"]

  gem.add_runtime_dependency "rdo", "~> 0.1.0"

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rake-compiler"
end
