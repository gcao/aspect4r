require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Aspect4r::Around do
  before do
    @klass = Class.new do
      include Aspect4r::Around
      
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
  
  it "should run advice method instead of original method" do
    @klass.class_eval do
      def do_something orig, value
        raise 'error'
      end
  
      around :test, :do_something
    end
    
    o = @klass.new
    lambda { o.test('something') }.should raise_error
  end
  
  it "should run advice block instead of original method" do
    i = 100
    
    @klass.class_eval do
      around :test do |orig, value|
        i = 200
        'around_block_return'
      end
    end
    
    o = @klass.new
    o.test('something').should == 'around_block_return'
    
    o.value.should == 'init'
    
    i.should == 200
  end
  
  it "should flatten arguments" do
    i = 100
    
    @klass.class_eval do
      around [:test] do |orig, value|
        i = 200
      end
    end
    
    o = @klass.new
    o.test('something')
    
    i.should == 200
  end
  
  it "should have access to instance variables inside advice block" do
    @klass.class_eval do
      around :test do |orig, value|
        @var = 1
      end
    end
    
    o = @klass.new
    o.test('something')
    
    o.instance_variable_get(:@var).should == 1
  end
  
  it "should be able to invoke original method from advice block" do
    i = 100
    
    @klass.class_eval do
      around :test do |proxy, value|
        i = 200
        a4r_invoke proxy, value
      end
    end
    
    o = @klass.new
    o.test('something').should == 'test_return'
    
    o.value.should == 'something'
    
    i.should == 200
  end
  
  it "should be able to invoke original method from advice method" do
    @klass.class_eval do
      def do_something proxy, value
        a4r_invoke proxy, value
      end
  
      around :test, :do_something
    end
    
    o = @klass.new
    o.test('something').should == 'test_return'
    
    o.value.should == 'something'
  end
  
  it "should pass method name to advice block(or method) as first arg if method_name_arg is true" do
    s = nil
    
    @klass.class_eval do
      around :test, :method_name_arg => true do |method, proxy, value|
        s = method
        a4r_invoke proxy, value
      end
    end
    
    o = @klass.new
    o.test('something')

    s.should == 'test'
  end
end
