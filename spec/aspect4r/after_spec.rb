require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Aspect4r::After do
  before do
    @klass = Class.new do
      include Aspect4r::After
      
      attr_accessor :value
      
      def initialize
        @value = 'init'
      end
    
      def test value
        @value = value
        'test_return'
      end
    end
  end
  
  it "should run block after method" do
    i = 100
    
    @klass.class_eval do
      after :test do |result, value|
        i = 200
        'after_test'
      end
    end
    
    o = @klass.new
    o.test('something').should == 'after_test'
    
    o.value.should == 'something'
    
    i.should == 200
  end
  
  it "should flatten arguments" do
    i = 100
    
    @klass.class_eval do
      after [:test] do |result, value|
        i = 200
      end
    end
    
    o = @klass.new
    o.test('something')
    
    i.should == 200
  end
  
  it "should have access to instance variable inside after block" do
    @klass.class_eval do
      after :test do |result, value|
        @var = 1
      end
    end
    
    o = @klass.new
    o.test('something')
    
    o.instance_variable_get(:@var).should == 1
  end  
  
  it "should pass method name as first arg if method_name_arg is true" do
    s = nil
    
    @klass.class_eval do
      after :test, :method_name_arg => true do |method, result, value|
        s = method
        result
      end
    end
    
    o = @klass.new
    o.test('something')

    s.should == 'test'
  end
  
  it "should run specified method after original method" do
    @klass.class_eval do
      def do_something result, value
        'do_something'
      end
  
      after :test, :do_something
    end
    
    o = @klass.new
    o.test('something').should == 'do_something'
  end
  
  it "should not pass result and not change result if result_arg is set to false" do
    @klass.class_eval do
      def do_something value
        'do_something'
      end
  
      after :test, :do_something, :result_arg => false
    end
    
    o = @klass.new
    o.test('something').should == 'test_return'
  end
end
