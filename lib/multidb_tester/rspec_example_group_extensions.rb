begin
  require "spec"
  MultidbTester.rspec = true
rescue LoadError
  MultidbTester.rspec = false
end

module MultidbTester
  module RspecExampleGroupExtensions
    def self.included(base)
      base.alias_method_chain :run, :multidb
      base.alias_method_chain :description_parts, :multidb
    end

    def run_with_multidb
      if MultidbTester.enabled && self.name != "MultidbRspecTest"
        success = true
        specs = MultidbTester::Utilities.connection_specs
        specs.sort{|a,b| a[0] <=> b[0]}.each do |conn_name, spec|
          ActiveRecord::Base.establish_connection(conn_name)
          MultidbTester.connection_spec_name = conn_name
          success = run_without_multidb
          p [success, conn_name]
          break if !success && conn_name == "test"
        end
        MultidbTester.connection_spec_name = nil
        success
      else
        run_without_multidb
      end
    end

    def description_parts_with_multidb
      if MultidbTester.enabled && self.name != "MultidbRspecTest" && MultidbTester.connection_spec_name != "test"
        description_parts_without_multidb + ["[#{MultidbTester.connection_spec_name} adapter]"]
      else
        description_parts_without_multidb
      end
    end
  end
end