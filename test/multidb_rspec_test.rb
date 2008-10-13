RAILS_ENV="test"

require 'test/unit'
require 'test/unit/ui/console/testrunner'
require "rubygems"
require "active_support"
ActiveSupport::Callbacks
require File.dirname(__FILE__) + "/../test_project/config/environment"
require File.dirname(__FILE__) + "/../lib/multidb_tester"
require 'spec'
require 'spec/rails'
require File.dirname(__FILE__) + "/../test_project/spec/models/something_spec"

#require "mocha"
#
#MultidbTester.enabled = false
#
#ActiveRecord::Base.establish_connection("test_multidb_sqlite3")
#ActiveRecord::Schema.define do
# create_table :somethings, :force => true do |t|
#   t.string :name
# end
#end
#
#ActiveRecord::Base.establish_connection("test")
#ActiveRecord::Schema.define do
# create_table :somethings, :force => true do |t|
#   t.string :name
# end
#end
#
#

#outstream = StringIO.new
#errstream = StringIO.new
#rspec_opts = Spec::Runner::Options.new(errstream, outstream)
#rspec_opts.examples_should_not_be_run
#rspec_runner = Spec::Runner.use(rspec_opts)
#

class QuietReporter < Spec::Runner::Reporter
  def example_finished(example, error=nil)
    @examples << example
  end
end

class MultidbRspecTest < Test::Unit::TestCase
  def setup
    MultidbTester.enabled = true
    @old_reporter = Spec::Runner.options.reporter
    Spec::Runner.options.reporter = QuietReporter.new(Spec::Runner.options)
  end

  def teardown
    # we don't want multidb extensions for THIS test file
    Spec::Runner.options.reporter = @old_reporter
    MultidbTester.enabled = false
  end

  def test_runs_test_once_for_each_db
    SomethingCounter.counter = 0
    assert run_spec(Spec::Rails::Example::ModelExampleGroup::Subclass_1, "should count")
    assert_equal 2, SomethingCounter.counter
  end

  def test_fails_in_primary_db__only_runs_once
    SomethingCounter.counter = 0
    assert !run_spec(Spec::Rails::Example::ModelExampleGroup::Subclass_1, "should count both invalid")
    assert_equal 1, SomethingCounter.counter
  end

  def test_both_databases_valid
    SomethingCounter.counter = 0
    assert run_spec(Spec::Rails::Example::ModelExampleGroup::Subclass_1, "should work")
    assert_equal 2, SomethingCounter.counter
  end

  def test_fails_mysql_only
    SomethingCounter.counter = 0
    assert !run_spec(Spec::Rails::Example::ModelExampleGroup::Subclass_1, "should work only with mysql")
    assert_equal 2, SomethingCounter.counter
  end

  def test_fails_sqlite_only
    SomethingCounter.counter = 0
    assert !run_spec(Spec::Rails::Example::ModelExampleGroup::Subclass_1, "should work only with sqlite")
    assert_equal 1, SomethingCounter.counter
  end

  def test_description
    MultidbTester.connection_spec_name = "bob"
    assert_equal "[bob adapter]", Spec::Rails::Example::ModelExampleGroup::Subclass_1.description_parts.last 
  end

  def test_fixtures
    p Spec::Rails::Example::ModelExampleGroup::Subclass_1.send(:before_each_parts)
    p Spec::Rails::Example::ModelExampleGroup::Subclass_1.superclass
    p Spec::Rails::Example::ModelExampleGroup::Subclass_1.superclass.send(:before_each_parts)
    p Spec::Rails::Example::ModelExampleGroup::Subclass_1.superclass.superclass
    p Spec::Rails::Example::ModelExampleGroup::Subclass_1.superclass.superclass.send(:before_each_parts)
    p Spec::Rails::Example::ModelExampleGroup::Subclass_1.superclass.superclass.superclass
    p Spec::Rails::Example::ModelExampleGroup::Subclass_1.superclass.superclass.superclass.send(:before_each_parts)
    assert run_spec(Spec::Rails::Example::ModelExampleGroup::Subclass_1, "should find fixtures")

  end

  def run_spec(spec_class, example_name)
#    p Spec::Runner.options.examples
    all_examples = spec_class.send(:examples_to_run)
    examples = all_examples.select{|e| e.description == example_name}
    spec_class.stubs(:examples_to_run).returns(examples)
    success = nil
    begin
      success = spec_class.run
    ensure
      spec_class.stubs(:examples_to_run).returns(all_examples)
    end
    success
  end
end

Spec::Runner.options.instance_variable_set(:@example_groups, [MultidbRspecTest])
