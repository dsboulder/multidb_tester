require "active_support/test_case"

module MultidbTester
  module TestcaseExtensions
    def self.included(base) 
      base.alias_method_chain :run, :multidb
      base.alias_method_chain :add_failure, :multidb
      base.alias_method_chain :add_error, :multidb
    end

    def run_with_multidb(result, &block)
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

    def add_failure_with_multidb(*args)
      if MultidbTester.enabled && MultidbTester.connection_spec_name
        oldname = @method_name
        @method_name = "#{oldname}[#{MultidbTester.connection_spec_name} adapter]" unless MultidbTester.connection_spec_name == "test"
        begin
          add_failure_without_multidb(*args)
        ensure
          @method_name = oldname
        end
      else
        add_failure_without_multidb(*args)        
      end
    end

    def add_error_with_multidb(*args)
      if MultidbTester.enabled && MultidbTester.connection_spec_name
        oldname = @method_name
        @method_name = "#{oldname}[#{MultidbTester.connection_spec_name} adapter]" unless MultidbTester.connection_spec_name == "test"
        begin
          add_error_without_multidb(*args)
        ensure
          @method_name = oldname
        end
      else
        add_error_without_multidb(*args)
      end
    end
  end
end