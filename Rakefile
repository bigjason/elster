#!/usr/bin/env rake
require "rubygems"
require "bundler/setup"

require "bundler/gem_tasks"

desc "Run all tests"
task :test do
  require 'turn'
  require "pry"
  require "test/unit"
  require "elster"
  require_relative "./test/streamer_test"
end
