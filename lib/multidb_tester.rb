# MultidbTester
module MultidbTester
  mattr_accessor :enabled
  mattr_accessor :connection_spec_name
  mattr_accessor :rspec

  self.enabled = true    
  self.rspec = false
end

require File.join(File.dirname(__FILE__), 'multidb_tester', 'testcase_extensions')
require File.join(File.dirname(__FILE__), 'multidb_tester', 'schema_extensions')
require File.join(File.dirname(__FILE__), 'multidb_tester', 'rspec_example_group_extensions')
require File.join(File.dirname(__FILE__), 'multidb_tester', 'utilities')

Test::Unit::TestCase.send(:include, MultidbTester::TestcaseExtensions)
ActiveRecord::Schema.send(:extend, MultidbTester::SchemaExtensions)
Spec::Example::ExampleGroupMethods.send(:include, MultidbTester::RspecExampleGroupExtensions) if MultidbTester.rspec 