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
    
    @klass.instance_eval do
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
    @klass.instance_eval do
      after_method :test, :use_return => true do |_self, result, value|
        'after_block_return'
      end
    end
    
    o = @klass.new
    o.test('something').should == 'after_block_return'
  end
  
  it "should use return value from original method if use_return option is not set" do
    @klass.instance_eval do
      after_method :test do |_self, result, value|
        'after_block_return'
      end
    end
    
    o = @klass.new
    o.test('something').should == 'test_return'
  end
  
  
  it "should run after_* after original method" do
    i = 100
    
    @klass.instance_eval do
      define_method :after_test do |result, value|
        i = 200
      end
  
      after_method :test, :method => :after_test
    end
    
    o = @klass.new
    o.test('something')

    o.value.should == 'something'
    
    i.should == 200
  end

  it "should use return value from after_* if use_return option is true" do
    @klass.instance_eval do
      define_method :after_test do |result, value|
        'after_test_return'
      end
  
      after_method :test, :method => :after_test, :use_return => true
    end
    
    o = @klass.new
    o.test('something').should == 'after_test_return'
  end

  it "should use return value from original method if use_return option is not set" do
    @klass.instance_eval do
      define_method :after_test do |result, value|
        'after_test_return'
      end
  
      after_method :test, :method => :after_test
    end
    
    o = @klass.new
    o.test('something').should == 'test_return'
  end
end
