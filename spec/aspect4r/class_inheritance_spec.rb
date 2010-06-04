require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Aspect4r do
  it "basic inheritance should work" do
    parent = Class.new do
      include Aspect4r
      
      attr :value
      
      def initialize
        @value = []
      end
      
      def test
        @value << "test"
      end
      
      around :test do |proxy|
        @value << "around1"
        send proxy
        @value << "around2"
      end
      
      before :test do
        @value << "before"
      end
      
      after :test do |result|
        @value << "after"
      end
    end
    
    child = Class.new(parent)
    
    o = child.new
    o.test
    
    o.value.should == %w(before around1 test around2 after)
  end
  
  it "override method" do
    parent = Class.new do
      include Aspect4r
      
      attr :value
      
      def initialize
        @value = []
      end
      
      def test
        @value << "test"
      end
      
      before :test do
        @value << "before"
      end
    end
    
    child = Class.new(parent) do
      def test
        @value << "test(child)"
      end
    end
    
    o = child.new
    o.test
    
    o.value.should == %w(test(child))
  end
  
  it "override method and call super" do
    parent = Class.new do
      include Aspect4r
      
      attr :value
      
      def initialize
        @value = []
      end
      
      def test
        @value << "test"
      end
      
      before :test do
        @value << "before"
      end
    end
    
    child = Class.new(parent) do
      def test
        super
        @value << "test(child)"
      end
    end
    
    o = child.new
    o.test
    
    o.value.should == %w(before test test(child))
  end
  
  it "before/after aspects in body and inherited aspects can be combined" do
    parent = Class.new do
      include Aspect4r
      
      attr :value
      
      def initialize
        @value = []
      end
      
      def test
        @value << "test"
      end
      
      before :test do
        @value << "before(parent)"
      end
      
      after :test do |result|
        @value << "after(parent)"
      end
    end
    
    class Child < parent
      include Aspect4r
      
      before :test do
        @value << "before"
      end
      
      after :test do |result|
        @value << "after"
      end
    end
    
    o = Child.new
    o.test
    
    o.value.should == %w(before before(parent) test after(parent) after)
  end
  
  it "around aspects in body and inherited aspects can be combined" do
    parent = Class.new do
      include Aspect4r
      
      attr :value
      
      def initialize
        @value = []
      end
      
      def test
        @value << "test"
      end
      
      before :test do
        @value << "before"
      end
      
      after :test do |result|
        @value << "after"
      end
    end
    
    class Child1 < parent
      include Aspect4r
      
      around :test do |proxy|
        @value << "around(before)"
        send proxy
        @value << "around(after)"
      end
    end
    
    o = Child1.new
    o.test
    
    o.value.should == %w(around(before) before test after around(after))
  end
end
