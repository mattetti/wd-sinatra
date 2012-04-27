require 'rbconfig'
require 'rake/testtask'
require 'rubygems'
require 'bundler'
Bundler.setup
require 'wd_sinatra/app_loader'

root = File.expand_path(File.dirname(__FILE__))

Rake::TestTask.new do |t|
  t.libs << "."
  t.libs << 'test'
  t.pattern = "test/**/*_test.rb"
end

task :default => :test

# boot the app
task :setup_app do
  ENV['DONT_CONNECT'] = 'true'
  WDSinatra::AppLoader.server(root)
end

task :environment do
  ENV['DONT_CONNECT'] = nil
  WDSinatra::AppLoader.server(root)
end

WDSinatra::AppLoader.set_loadpath(root)
Dir.glob("lib/tasks/**/*.rake").each do |task_file|
  load task_file
end
