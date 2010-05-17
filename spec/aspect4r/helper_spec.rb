require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Aspect4r::Helper" do
  it "should return test0 as first available method" do
    Aspect4r::Helper.find_available_method_name(Class.new, "test").should =~ /test0/
  end
  
  it "should return test1 if find_available_method_name is called once already" do
    klass = Class.new
    klass.class_eval do
      define_method Aspect4r::Helper.find_available_method_name(klass, "test") do
      end
    end
    Aspect4r::Helper.find_available_method_name(klass, "test").should =~ /test1/
  end
end
