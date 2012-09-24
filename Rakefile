require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rake/extensiontask"

Rake::ExtensionTask.new('rdo_sqlite') do |ext|
  ext.lib_dir = File.join('lib', 'rdo_sqlite')
end

desc "Run the full RSpec suite"
RSpec::Core::RakeTask.new('spec') do |t|
  t.pattern     = 'spec/'
end

Rake::Task['spec'].prerequisites << :compile
