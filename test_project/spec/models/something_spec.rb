require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class SomethingCounter
  cattr_accessor :counter
end

describe Something do
  fixtures :somethings
  
  before(:each) do
    @valid_attributes = {
    }
  end

  it "should count" do
    SomethingCounter.counter += 1    
  end

  it "should count both invalid" do
    SomethingCounter.counter += 1
    raise "hello"
  end

  it "should work" do
    ActiveRecord::Base.connection.select_values("SELECT * FROM somethings")
    SomethingCounter.counter += 1
  end

  it "should work only with mysql" do
    SomethingCounter.counter += 1
    assert_equal "0", ActiveRecord::Base.connection.select_values("SELECT SIN(0)").first
  end

  it "should work only with sqlite" do
    SomethingCounter.counter += 1
    ActiveRecord::Base.connection.select_values("SELECT hex(randomblob(1))")
  end

  it "should find fixtures" do
    Something.find_by_id(1).should_not == nil
  end
end
