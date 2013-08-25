ENV['RACK_ENV'] ||= 'test'
require 'rubygems'
require 'bundler'
Bundler.setup
require 'test/unit'

$: << File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'wd_sinatra'
