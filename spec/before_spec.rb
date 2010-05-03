require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Aspect4r - before_method" do
  before do
    @klass = Class.new do
      include Aspect4r
      
      attr_accessor :value
      
      def initialize
        @value = 'init'
      end
    
      def test value
        @value = value
      end
    end
  end
  
  it "should run block before method" do
    i = 100
    
    @klass.instance_eval do
      before_method :test do |_self, value|
        i = 200
      end
    end
    
    o = @klass.new
    o.test('something')
    
    o.value.should == 'something'
    
    i.should == 200
  end
  
  it "should skip method if block returns false and skip_if_false option is true" do
    @klass.instance_eval do
      before_method :test, :skip_if_false => true do |_self, value|
        false
      end
    end
    
    o = @klass.new
    o.test('something').should be_false

    o.value.should == 'init'
  end
  
  it "should skip method if block returns nil and skip_if_false option is true" do
    @klass.instance_eval do
      before_method :test, :skip_if_false => true do |_self, value|
        nil
      end
    end
    
    o = @klass.new
    o.test('something').should be_nil

    o.value.should == 'init'
  end
  
  it "should not skip method if block did not return false and skip_if_false is not specified" do
    @klass.instance_eval do
      before_method :test do |_self, value|
        false
      end
    end
    
    o = @klass.new
    o.test('something')

    o.value.should == 'something'
  end
  
  it "should run before_* before original method" do
    i = 100
    
    @klass.instance_eval do
      define_method :before_test do |value|
        i = 200
      end

      before_method :test, :method => :before_test
    end
    
    o = @klass.new
    o.test('something')
    
    o.value.should == 'something'
    
    i.should == 200
  end
  
  it "should skip original method if before_* returns false and skip_if_false is true" do
    @klass.instance_eval do
      define_method :before_test do |value|
        false
      end

      before_method :test, :method => :before_test, :skip_if_false => true
    end
    
    o = @klass.new
    o.test('something').should be_false
    
    o.value.should == 'init'
  end
  
  it "should default to before_xxx method if block is not given and method option is not specified" do
    i = 100
    
    @klass.instance_eval do
      define_method :before_test do |value|
        i = 200
      end

      before_method :test
    end
    
    o = @klass.new
    o.test('something')
    
    o.value.should == 'something'
    
    i.should == 200
  end
  
  it "before_method_check" do
    @klass.instance_eval do
      define_method :before_test do |value|
        false
      end

      before_method_check :test
    end
    
    o = @klass.new
    o.test('something').should be_false
    
    o.value.should == 'init'
  end
end
