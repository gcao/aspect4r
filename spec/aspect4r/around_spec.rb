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
  
  it "should run block instead of original method" do
    i = 100
    
    @klass.class_eval do
      around_method :test do |orig_method, value|
        i = 200
        'around_block_return'
      end
    end
    
    o = @klass.new
    o.test('something').should == 'around_block_return'
    
    o.value.should == 'init'
    
    i.should == 200
  end
  
  it "should have access to instance variable inside around block" do
    @klass.class_eval do
      around_method :test do |orig_method, value|
        @var = 1
      end
    end
    
    o = @klass.new
    o.test('something')
    
    o.instance_variable_get(:@var).should == 1
  end
  
  it "should be able to invoke original method" do
    i = 100
    
    @klass.class_eval do
      around_method :test do |orig_method, value|
        i = 200
        send orig_method, value
      end
    end
    
    o = @klass.new
    o.test('something').should == 'test_return'
    
    o.value.should == 'something'
    
    i.should == 200
  end
  
  it "should pass method name as first arg if method_name_arg is true" do
    s = nil
    
    @klass.class_eval do
      around_method :test, :method_name_arg => true do |method, orig_method, value|
        s = method
        send orig_method, value
      end
    end
    
    o = @klass.new
    o.test('something')

    s.should == 'test'
  end
  
  it "should run around_* method instead of original method" do
    @klass.class_eval do
      def do_something orig_method, value
        raise 'error'
      end
  
      around_method :test, :do_something
    end
    
    o = @klass.new
    lambda { o.test('something') }.should raise_error
  end
  
  it "should be able to invoke original method from around_* method" do
    @klass.class_eval do
      def do_something orig_method, value
        send orig_method, value
      end
  
      around_method :test, :do_something
    end
    
    o = @klass.new
    o.test('something').should == 'test_return'
    
    o.value.should == 'something'
  end
end
