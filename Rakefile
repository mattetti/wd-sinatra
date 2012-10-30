#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "."
  t.libs << 'test'
  t.pattern = "test/**/**.rb"
end

task :default => :test
