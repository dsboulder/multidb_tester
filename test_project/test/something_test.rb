require File.dirname(__FILE__) + '/test_helper'

class SomethingTest < Test::Unit::TestCase #ActiveSupport::TestCase
  cattr_accessor :counter
  # Replace this with your real tests.
  def test_increment_counter
    self.counter ||= 0
    self.counter += 1
    assert true
  end

  def test_select_function__mysql_only
    assert_equal "0", ActiveRecord::Base.connection.select_values("SELECT SIN(0)").first
  end

  def test_select_function__sqlite_only
    ActiveRecord::Base.connection.select_values("SELECT hex(randomblob(1))")
  end

  def test_select_function__invalid
    ActiveRecord::Base.connection.select_values("SELECT omgpewpewpew!!!")
  end

  def test_fails
    assert false
  end
end
