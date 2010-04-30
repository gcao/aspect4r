require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Aspect4r - around_method" do
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
  
  it "should run block instead of original method" do
    i = 100
    
    @klass.instance_eval do
      around_method :test do |value, _self|
        i = 200
        'around_block_return'
      end
    end
    
    o = @klass.new
    o.test('something').should == 'around_block_return'
    
    o.value.should == 'init'
    
    i.should == 200
  end
  
  it "should be able to invoke original method" do
    i = 100
    
    @klass.instance_eval do
      around_method :test do |_self, orig_method, value|
        i = 200
        _self.send orig_method, value
      end
    end
    
    o = @klass.new
    o.test('something').should == 'test_return'
    
    o.value.should == 'something'
    
    i.should == 200
  end
  
  it "should run around_* method instead of original method" do
    i = 100
    
    @klass.instance_eval do
      define_method :around_test do |orig_method, value|
        i = 200
        'around_test_return'
      end
  
      around_method :test, :method => :around_test
    end
    
    o = @klass.new
    o.test('something').should == 'around_test_return'
    
    o.value.should == 'init'
    
    i.should == 200
  end
  
  it "should be able to invoke original method from around_* method" do
    i = 100
    
    @klass.instance_eval do
      define_method :around_test do |orig_method, value|
        i = 200
        send orig_method, value
      end
  
      around_method :test, :method => :around_test
    end
    
    o = @klass.new
    o.test('something').should == 'test_return'
    
    o.value.should == 'something'
    
    i.should == 200
  end
end
