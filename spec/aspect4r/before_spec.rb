require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Aspect4r::Before do
  before do
    @klass = Class.new do
      include Aspect4r::Before

      attr :value

      def initialize
        @value = 'init'
      end

      def test value
        @value = value
      end
    end
  end

  it "should run advice method before original method" do
    @klass.class_eval do
      def do_something value
        raise 'error'
      end

      before :test, :do_something
    end

    o = @klass.new
    lambda { o.test('something') }.should raise_error('error')
  end

  it "should run advice block before original method" do
    i = 100

    @klass.class_eval do
      before :test do |value|
        i = 200
      end
    end

    o = @klass.new
    o.test('something').should == 'something'

    o.value.should == 'something'

    i.should == 200
  end

  it "should flatten arguments" do
    i = 100

    @klass.class_eval do
      before [:test] do |value|
        i = 200
      end
    end

    o = @klass.new
    o.test('something').should == 'something'

    o.value.should == 'something'

    i.should == 200
  end

  it "should have access to instance variables inside advice block" do
    @klass.class_eval do
      before :test do |value|
        @var = 1
      end
    end

    o = @klass.new
    o.test('something')

    o.instance_variable_get(:@var).should == 1
  end

  it "should not skip method if before advice returned false" do
    @klass.class_eval do
      before :test do |value|
        false
      end
    end

    o = @klass.new
    o.test('something')

    o.value.should == 'something'
  end

  it "should pass method name as first arg to before advice block(or method) if method_name_arg is true" do
    s = nil

    @klass.class_eval do
      before :test, :method_name_arg => true do |method, value|
        s = method
      end
    end

    o = @klass.new
    o.test('something')

    s.should == 'test'
  end

  it "should skip original method if before advice returned instance of ReturnThis" do
    @klass.class_eval do
      def do_something value
        Aspect4r::ReturnThis.new('do_something')
      end

      before :test, :do_something
    end

    o = @klass.new
    o.test('something').should == 'do_something'

    o.value.should == 'init'
  end

  it "should skip original method if before_filter advice returned false" do
    @klass.class_eval do
      before_filter :test do |value|
        false
      end
    end

    o = @klass.new
    o.test('something').should be_falsy

    o.value.should == 'init'
  end

  it "should not skip original method if before_filter did not return false or nil" do
    @klass.class_eval do
      before_filter :test do |value|
        true
      end
    end

    o = @klass.new
    o.test('something')

    o.value.should == 'something'
  end

  it "should not apply advice on the advice method itself" do
    klass = Class.new do
      include Aspect4r

      attr :value

      before :test, :test

      def initialize
        @value = 0
      end

      def test
        @value += 1
      end
    end

    obj = klass.new
    obj.test
    obj.value.should == 1
  end

  it ":new_methods_only option" do
    @klass.class_eval do
      def do_something value
        raise 'error'
      end

      def test1
        @value = 'test1'
      end

      before /test/, :do_something, :new_methods_only => false
    end

    o = @klass.new
    lambda { o.test('something') }.should raise_error('error')
  end
end

describe Aspect4r::Before do
  it "apply to next method to be created" do
    @klass = Class.new do
      include Aspect4r::Before

      attr :value

      def initialize
        @value = []
      end

      before { @value << 'before' }
      def test
        @value << 'test'
      end
    end

    o = @klass.new
    o.test
    o.value.should == %w(before test)
  end
end

