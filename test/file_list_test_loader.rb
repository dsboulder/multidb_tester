#!/usr/bin/env ruby

require "test/unit"
require "test/unit/testsuite"
require "rubygems"
require "activesupport"

# Load the test files from the command line.
autorunner = Test::Unit::AutoRunner.new(true) do |a|
  a.collector = Proc.new {|r|
    suite = Test::Unit::TestSuite.new(ARGV.inspect)
    classes = ARGV.collect do |file|
      load(Dir.pwd + "/" + file)
      suite << File.basename(file, ".rb").camelize.constantize.suite
    end
    suite
  }
end

autorunner.run