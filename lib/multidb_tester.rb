# MultidbTester
require File.join(File.dirname(__FILE__), 'multidb_tester', 'testcase_extensions')
require File.join(File.dirname(__FILE__), 'multidb_tester', 'schema_extensions')
require File.join(File.dirname(__FILE__), 'multidb_tester', 'utilities')

Test::Unit::TestCase.send(:include, MultidbTester::TestcaseExtensions)
ActiveRecord::Schema.send(:extend, MultidbTester::SchemaExtensions)

module MultidbTester
  include MultidbTester::Utilities
  
  mattr_accessor :enabled
  mattr_accessor :connection_spec_name
  self.enabled = true
end