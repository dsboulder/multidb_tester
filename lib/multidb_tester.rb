# MultidbTester
require File.join(File.dirname(__FILE__), 'multidb_tester', 'testcase_extensions')
require File.join(File.dirname(__FILE__), 'multidb_tester', 'schema_extensions')
require File.join(File.dirname(__FILE__), 'multidb_tester', 'rspec_options_extensions')
require File.join(File.dirname(__FILE__), 'multidb_tester', 'utilities')

module MultidbTester
  mattr_accessor :enabled
  mattr_accessor :connection_spec_name
  mattr_accessor :rspec
  
  self.enabled = true
end

Test::Unit::TestCase.send(:include, MultidbTester::TestcaseExtensions)
ActiveRecord::Schema.send(:extend, MultidbTester::SchemaExtensions)
Spec::Runer::Options.send(:extend, MultidbTester::SchemaExtensions) if MultidbTester.rspec