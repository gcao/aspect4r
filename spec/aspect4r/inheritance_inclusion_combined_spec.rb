require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Aspect4r do
  it "inherit aspects from parent class which include aspects from module" do
    module Mod
      include Aspect4r
      
      around :test do |proxy|
        @value << "around1"
        proxy.bind(self).call
        @value << "around2"
      end
      
      before :test do
        @value << "before"
      end
      
      after :test do |result|
        @value << "after"
      end
    end
    
    parent = Class.new do
      include Mod
      
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
    module Mod2
      include Aspect4r
      
      around :test do |proxy|
        @value << "around1"
        proxy.bind(self).call
        @value << "around2"
      end
      
      before :test do
        @value << "before"
      end
      
      after :test do |result|
        @value << "after"
      end
    end
    
    parent = Class.new do
      include Mod2
      
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
    module Mod3
      include Aspect4r
      
      around :test do |proxy|
        @value << "around1"
        proxy.bind(self).call
        @value << "around2"
      end
      
      before :test do
        @value << "before(module)"
      end
      
      after :test do |result|
        @value << "after"
      end
    end
    
    class Parent3
      include Aspect4r
      
      before :test do
        @value << "before(parent)"
      end
      
      attr :value
      
      def initialize
        @value = []
      end
    end
    
    class Child3 < Parent3
      include Mod3
      
      def test_without_a4r
        @value << "test"
      end
    end
    
    
    o = Child3.new
    o.test
    
    o.value.should == %w(before(module) around1 before(parent) test around2 after)
  end
end
