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
      
      around :test do |&block|
        @value << "around1"
        block.call
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
        @value << "test(parent)"
      end
      
      before :test do
        @value << "before"
      end
    end
    
    child = Class.new(parent) do
      def test
        @value << "test"
      end
    end
    
    o = child.new
    o.test
    
    o.value.should == %w(test)
  end
  
  it "override method and call super" do
    parent = Class.new do
      include Aspect4r
      
      attr :value
      
      def initialize
        @value = []
      end
      
      def test
        @value << "test(parent)"
      end
      
      before :test do
        @value << "before"
      end
    end
    
    child = Class.new(parent) do
      def test
        super
        @value << "test"
      end
    end
    
    o = child.new
    o.test
    
    o.value.should == %w(before test(parent) test)
  end
  
  it "override method with advices and call super" do
    parent = Class.new do
      include Aspect4r
      
      attr :value
      
      def initialize
        @value = []
      end
      
      def test
        @value << "test(parent)"
      end
      
      before :test do
        @value << "before(parent)"
      end
    end
    
    child = Class.new(parent) do
      include Aspect4r
      
      def test
        super
        @value << "test"
      end
      
      before :test do
        @value << "before"
      end
    end
    
    o = child.new
    o.test
    
    o.value.should == %w(before before(parent) test(parent) test)
  end
  
  it "method+advices in child class and method+advices in parent class" do
    parent = Class.new do
      include Aspect4r
      
      attr :value
      
      def initialize
        @value = []
      end
      
      def test
        @value << "test(parent)"
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
    
    o = Child.new
    o.test
    
    o.value.should == %w(before test after)
  end
  
  it "around advice in child class and method in parent class" do
    parent = Class.new do
      attr :value
      
      def initialize
        @value = []
      end
      
      def test
        @value << "test"
      end
    end
    
    class Child1 < parent
      include Aspect4r
      
      around :test do |&block|
        @value << "around(before)"
        block.call
        @value << "around(after)"
      end
    end
    
    o = Child1.new
    o.test
    
    o.value.should == %w(around(before) test around(after))
  end
  
  it "around advice in child class and method+advices in parent class" do
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
    
    class Child2 < parent
      include Aspect4r
      
      around :test do |&block|
        @value << "around(before)"
        block.call
        @value << "around(after)"
      end
    end
    
    o = Child2.new
    o.test
    
    o.value.should == %w(around(before) before test after around(after))
  end
end
