require "rdo"
require "rdo/sqlite"

ENV["CONNECTION"] ||= "sqlite://memory?encoding=utf-8"

RSpec.configure do |config|
  def connection_uri
    ENV["CONNECTION"]
  end
end
