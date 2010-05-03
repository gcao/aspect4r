require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Aspect4r - after_method" do
  before do
    @klass = Class.new do
      include Aspect4r
      
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
      after_method :test do |_self, result, value|
        i = 200
      end
    end
    
    o = @klass.new
    o.test('something')
    
    o.value.should == 'something'
    
    i.should == 200
  end
  
  it "should use return value from after block if use_return option is true" do
    @klass.class_eval do
      after_method :test, :use_return => true do |_self, result, value|
        'after_block_return'
      end
    end
    
    o = @klass.new
    o.test('something').should == 'after_block_return'
  end
  
  it "should use return value from original method if use_return option is not set" do
    @klass.class_eval do
      after_method :test do |_self, result, value|
        'after_block_return'
      end
    end
    
    o = @klass.new
    o.test('something').should == 'test_return'
  end
  
  
  it "should run specified method after original method" do
    @klass.class_eval do
      def do_something result, value
        raise 'error'
      end
  
      after_method :test, :method => :do_something
    end
    
    o = @klass.new
    lambda { o.test('something') }.should raise_error
  end

  it "should use return value from after_* if use_return option is true" do
    @klass.class_eval do
      def after_test result, value
        'after_test_return'
      end
  
      after_method :test, :method => :after_test, :use_return => true
    end
    
    o = @klass.new
    o.test('something').should == 'after_test_return'
  end

  it "should use return value from original method if use_return option is not set" do
    @klass.class_eval do
      def after_test result, value
        'after_test_return'
      end
  
      after_method :test, :method => :after_test
    end
    
    o = @klass.new
    o.test('something').should == 'test_return'
  end
  
  it "should default to after_xxx method if block is not given and method option is not specified" do
    @klass.class_eval do
      def after_test result, value
        raise 'error'
      end
  
      after_method :test
    end
    
    o = @klass.new
    lambda { o.test('something') }.should raise_error
  end
  
  it "after_method_process" do
    @klass.class_eval do
      def after_test result, value
        'after_test_return'
      end

      after_method_process :test
    end
    
    o = @klass.new
    o.test('something').should == 'after_test_return'
  end
end
