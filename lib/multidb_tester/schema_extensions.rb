require "active_record/schema"

module MultidbTester
  module SchemaExtensions
    def self.extended(base)
      base.instance_eval do
        class << self
          alias_method_chain :define, :multidb
        end
      end
    end

    def define_with_multidb(info={}, &block)
      if MultidbTester.enabled
        specs = MultidbTester::Utilities.connection_specs
        specs.sort{|a,b| a[0] <=> b[0]}.each do |conn_name, spec|
#          puts "Running on #{conn_name}: #{self.inspect}"
          ActiveRecord::Base.establish_connection(conn_name)
          define_without_multidb(info={}, &block)
        end
        ActiveRecord::Base.establish_connection
      else
        define_without_multidb(info={}, &block)
      end
    end
  end
end