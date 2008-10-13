RAILS_ENV="test"

require 'test/unit'
require 'test/unit/ui/console/testrunner'
require File.dirname(__FILE__) + "/../test_project/config/environment"
require File.dirname(__FILE__) + "/../lib/multidb_tester"
require File.dirname(__FILE__) + "/../test_project/test/something_test"

require "mocha"

MultidbTester.enabled = false

ActiveRecord::Base.establish_connection("test_multidb_sqlite3")
ActiveRecord::Schema.define do
 create_table :somethings, :force => true do |t|
   t.string :name
 end
end

ActiveRecord::Base.establish_connection("test")
ActiveRecord::Schema.define do
 create_table :somethings, :force => true do |t|
   t.string :name
 end
end

class MultidbTesterTest < Test::Unit::TestCase
  def setup    
    MultidbTester.enabled = true
  end

  def teardown
    # we don't want multidb extensions for THIS test file
    MultidbTester.enabled = false
  end

  def test_runs_test_once_for_each_db
    SomethingTest.counter = 0
    assert run_test(SomethingTest, "test_increment_counter").passed?
    assert_equal 2, SomethingTest.counter
  end

  def test_mysql_passes_and_sqlite_fails__runs_both
    result = run_test(SomethingTest, "test_select_function__mysql_only")
    assert_equal false, result.passed?
    assert_equal 2, result.run_count
    assert_equal 1, result.error_count
    p result
  end

  def test_mysql_fails_and_sqlite_passes__runs_only_mysql
    result = run_test(SomethingTest, "test_select_function__sqlite_only")
    assert_equal false, result.passed?
    assert_equal 1, result.run_count
    assert_equal 1, result.error_count
    p result
  end

  def test_both_fail
    result = run_test(SomethingTest, "test_select_function__invalid")
    assert_equal false, result.passed?
    assert_equal 1, result.run_count
    assert_equal 1, result.error_count
    p result
  end

  def test_sets_connection_initially_to_primary_database_then_to_sec_database
    ActiveRecord::Base.expects(:establish_connection).with("test")
    ActiveRecord::Base.expects(:establish_connection).with("test_multidb_sqlite3")
    run_test(SomethingTest, "test_increment_counter")
  end

  def test_multidb_connection_specs
    expected_connections = {"test" => ActiveRecord::Base.configurations["test"],
      "test_multidb_sqlite3" => ActiveRecord::Base.configurations["test_multidb_sqlite3"]}
    assert_equal expected_connections, MultidbTester::Utilities.connection_specs
  end

  def test_add_error__doesnt_include_adapter_name__when_test
    result = run_test(SomethingTest, "test_select_function__invalid")
    errors = result.instance_variable_get(:@errors)
    assert_equal "test_select_function__invalid(SomethingTest)", errors.first.test_name
  end

  def test_add_error__doesnt_include_adapter_name__when_test
    result = run_test(SomethingTest, "test_select_function__mysql_only")
    errors = result.instance_variable_get(:@errors)
    assert_equal "test_select_function__mysql_only[test_multidb_sqlite3 adapter](SomethingTest)", errors.first.test_name
  end

  def test_add_failure
    result = run_test(SomethingTest, "test_fails")
    errors = result.instance_variable_get(:@failures)
    assert_equal "test_fails(SomethingTest)", errors.first.test_name
  end

  def test_define_schema__runs_on_each_db
    field_name = "unique_#{Process.pid}"
    assert !get_fields_for_spec_name("test").include?(field_name)
    assert !get_fields_for_spec_name("test_multidb_sqlite3").include?(field_name)
    ActiveRecord::Schema.define do
      create_table :stuffs, :force => true do |t|
        t.string field_name
      end
    end
    assert get_fields_for_spec_name("test").include?(field_name)
    assert get_fields_for_spec_name("test_multidb_sqlite3").include?(field_name)
  end

  def test_fixtures
    result = run_test(SomethingTest, "test_fixtures2")
    assert result.passed?
  end
  
  def get_fields_for_spec_name(spec_name, table_name = "stuffs")
    ActiveRecord::Base.establish_connection(spec_name)
    cols = ActiveRecord::Base.connection.columns(table_name).collect{|c| c.name} rescue []
    ActiveRecord::Base.establish_connection
    cols
  end

  def run_test(test_class, test_method = :all)
    suite = test_class.suite
    if test_method != :all
      to_delete = []
      suite.tests.each do |test|        
        to_delete << test unless test.method_name == test_method
      end
      to_delete.each do |test|
        suite.delete(test)
      end
    end
    runner = Test::Unit::UI::Console::TestRunner.new(suite, Test::Unit::UI::SILENT)
    runner.start
  end

  def run_spec(spec_class)

  end
end