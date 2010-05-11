require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Aspect4r - before_method" do
  before do
    @klass = Class.new do
      include Aspect4r
      
      attr :value
      
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
    
    @klass.class_eval do
      before_method :test do |value|
        i = 200
      end
    end
    
    o = @klass.new
    o.test('something').should == 'something'
    
    o.value.should == 'something'
    
    i.should == 200
  end
  
  it "should have access to instance variable inside before block" do
    @klass.class_eval do
      before_method :test do |value|
        @var = 1
      end
    end
    
    o = @klass.new
    o.test('something')
    
    o.instance_variable_get(:@var).should == 1
  end
  
  it "should skip method if block returns false and skip_if_false option is true" do
    @klass.class_eval do
      before_method :test, :skip_if_false => true do |value|
        false
      end
    end
    
    o = @klass.new
    o.test('something').should be_false

    o.value.should == 'init'
  end
  
  it "should skip method if block returns nil and skip_if_false option is true" do
    @klass.class_eval do
      before_method :test, :skip_if_false => true do |value|
        nil
      end
    end
    
    o = @klass.new
    o.test('something').should be_nil

    o.value.should == 'init'
  end
  
  it "should not skip method if block did not return false and skip_if_false is not specified" do
    @klass.class_eval do
      before_method :test do |value|
        false
      end
    end
    
    o = @klass.new
    o.test('something')

    o.value.should == 'something'
  end
  
  it "should run before_* before original method" do
    @klass.class_eval do
      def do_something value
        raise 'error'
      end

      before_method :test, :do_something
    end
    
    o = @klass.new
    lambda { o.test('something') }.should raise_error('error')
  end
  
  it "should skip original method if before_* returns false and skip_if_false is true" do
    @klass.class_eval do
      def do_something value
        false
      end

      before_method :test, :do_something, :skip_if_false => true
    end
    
    o = @klass.new
    o.test('something').should be_false
    
    o.value.should == 'init'
  end
  
  it "before_method_check" do
    @klass.class_eval do
      before_method_check :test do
        false
      end
    end
    
    o = @klass.new
    o.test('something').should be_false
    
    o.value.should == 'init'
  end
end
