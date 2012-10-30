ENV['RACK_ENV'] ||= 'test'
require 'rubygems'
require 'bundler'
Bundler.setup
require 'test/unit'
if RUBY_VERSION.to_f < 1.9
  require 'minitest/autorun'
end

$: << File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'wd_sinatra'

