require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Aspect4r do
  it "inherit aspects from parent class which include aspects from module" do
    module SimpleMod
      include Aspect4r
      
      before_method :test do
        @value << "before"
      end
      
      after_method :test do |result|
        @value << "after"
      end
      
      around_method :test do |proxy_method|
        @value << "around1"
        send proxy_method
        @value << "around2"
      end
    end
    
    parent = Class.new do
      include SimpleMod
      
      attr :value
      
      def initialize
        @value = []
      end
    end
    
    child = Class.new(parent) do
      def test_without_a4r
        @value << "test"
      end
    end
    
    
    o = child.new
    o.test
    
    o.value.should == %w(before around1 test around2 after)
  end
  
  it "method in parent class need to be renamed to xxx_without_a4r if it is after aspects are defined, and can be called from child class" do
    module SimpleMod2
      include Aspect4r
      
      before_method :test do
        @value << "before"
      end
      
      after_method :test do |result|
        @value << "after"
      end
      
      around_method :test do |proxy_method|
        @value << "around1"
        send proxy_method
        @value << "around2"
      end
    end
    
    parent = Class.new do
      include SimpleMod2
      
      attr :value
      
      def initialize
        @value = []
      end
      
      def test_without_a4r
        @value << "test(parent)"
      end
    end
    
    child = Class.new(parent) do
      def test_without_a4r
        super
        @value << "test(child)"
      end
    end
    
    
    o = child.new
    o.test
    
    o.value.should == %w(before around1 test(parent) test(child) around2 after)
  end
  
  it "mix aspects in parent class and included modules" do
    module SimpleMod3
      include Aspect4r
      
      before_method :test do
        @value << "before(module)"
      end
      
      after_method :test do |result|
        @value << "after"
      end
      
      around_method :test do |proxy_method|
        @value << "around1"
        send proxy_method
        @value << "around2"
      end
    end
    
    class Parent
      include Aspect4r
      
      before_method :test do
        @value << "before(parent)"
      end
      
      attr :value
      
      def initialize
        @value = []
      end
    end
    
    class Child < Parent
      include SimpleMod3
      
      def test_without_a4r
        @value << "test"
      end
    end
    
    
    o = Child.new
    o.test
    
    o.value.should == %w(before(parent) before(module) around1 test around2 after)
  end
end
