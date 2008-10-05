#Slimmed down from test_help.rb in rails

require 'test/unit'
require 'active_support/test_case'
require 'active_record/fixtures'

Test::Unit::TestCase.fixture_path = RAILS_ROOT + "/test/fixtures/"

def create_fixtures(*table_names)
  Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names)
end
