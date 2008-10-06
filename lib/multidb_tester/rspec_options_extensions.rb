begin
  require "spec"
  MultidbTester.rspec = true
rescue LoadError
  MultidbTester.rspec = false
end

module MultidbTester
  module RspecOptionsExtensions
    def self.included(base) 
      base.alias_method_chain :run_examples, :multidb
    end

    def run_examples_with_multidb(result, &block)
      if MultidbTester.enabled
        specs = MultidbTester::Utilities.connection_specs
        specs.sort{|a,b| a[0] <=> b[0]}.each do |conn_name, spec|
          ActiveRecord::Base.establish_connection(conn_name)
          MultidbTester.connection_spec_name = conn_name
          old_bad_count = result.failure_count + result.error_count
          run_without_multidb(result, &block)
          new_bad_count = result.failure_count + result.error_count
          failed = (new_bad_count > old_bad_count)
          break if failed && conn_name == "test"
        end
        MultidbTester.connection_spec_name = nil
      else
        run_without_multidb(result, &block)
      end
    end
  end
end