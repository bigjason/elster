#!/usr/bin/env rake
require "rubygems"
require "bundler/setup"
Bundler.require

require "bundler/gem_tasks"
require "benchmark"

desc "Run all tests"
task :test do
  require 'turn'
  require "pry"
  require "test/unit"
  require_relative "./test/streamer_test"
end

desc "Run a simple benchmark"
task :benchmark do
  require "stringio"
  ITERATIONS = 100000

  Benchmark.bm do |x|
    x.report("Elster  ") do
      result = Elster::Streamer.new StringIO.new
      ITERATIONS.times do |i|
        result.key("name_#{i}", "Jason #{i}")
        result.key("age_#{i}", i)
        result.key("nil_#{i}", nil)
      end
      result.close
    end

    x.report("Hash    ") do
      result = {}
      ITERATIONS.times do |i|
        result["name_#{i}"] = "Jason #{i}"
        result["age_#{i}"] = i
        result["nil_#{i}"] = nil
      end
      MultiJson.dump(result)
    end
  end

end
