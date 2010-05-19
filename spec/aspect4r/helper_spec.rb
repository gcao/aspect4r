require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Aspect4r::Helper do
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
  
  describe "self.create_method" do
    before do
      @klass = Class.new do
        include Aspect4r
        
        attr :value
        
        def initialize
          @value = []
        end
        
        def test_without_a4r
          @value << "test_without_a4r"
        end
        
        def before_test
          @value << "before_test"
        end
        
        def after_test result
          @value << "after_test"
          result
        end
        
        def around_test proxy_method
          @value << "around_test_before"
          result = send(proxy_method)
          @value << "around_test_after"
          result
        end
      end
    end
    
    it "aspect is nil" do
      Aspect4r::Helper.create_method @klass, :test, nil
      
      o = @klass.new
      o.test
      
      o.value.should == %w(test_without_a4r)
    end
    
    it "aspect is empty" do
      Aspect4r::Helper.create_method @klass, :test, Aspect4r::AspectForMethod.new(:test)
      
      o = @klass.new
      o.test
      
      o.value.should == %w(test_without_a4r)
    end
    
    it "before aspect" do
      aspect = Aspect4r::AspectForMethod.new(:test)
      aspect.add(Aspect4r::Definition.before :before_test)
      Aspect4r::Helper.create_method @klass, :test, aspect
      
      o = @klass.new
      o.test
      
      o.value.should == %w(before_test test_without_a4r)
    end
    
    it "after aspect" do
      aspect = Aspect4r::AspectForMethod.new(:test)
      aspect.add(Aspect4r::Definition.after :after_test)
      Aspect4r::Helper.create_method @klass, :test, aspect
      
      o = @klass.new
      o.test
      
      o.value.should == %w(test_without_a4r after_test)
    end
    
    it "around aspect" do
      aspect = Aspect4r::AspectForMethod.new(:test)
      aspect.add(Aspect4r::Definition.around :around_test)
      Aspect4r::Helper.create_method @klass, :test, aspect
      
      o = @klass.new
      o.test
      
      o.value.should == %w(around_test_before test_without_a4r around_test_after)
    end
    
    it "before + after" do
      aspect = Aspect4r::AspectForMethod.new(:test)
      aspect.add(Aspect4r::Definition.before :before_test)
      aspect.add(Aspect4r::Definition.after :after_test)
      Aspect4r::Helper.create_method @klass, :test, aspect
      
      o = @klass.new
      o.test
      
      o.value.should == %w(before_test test_without_a4r after_test)
    end
    
    it "before + after + around" do
      aspect = Aspect4r::AspectForMethod.new(:test)
      aspect.add(Aspect4r::Definition.before :before_test)
      aspect.add(Aspect4r::Definition.after :after_test)
      aspect.add(Aspect4r::Definition.around :around_test)
      Aspect4r::Helper.create_method @klass, :test, aspect
      
      o = @klass.new
      o.test
      
      o.value.should == %w(before_test around_test_before test_without_a4r around_test_after after_test)
    end
  end
end
