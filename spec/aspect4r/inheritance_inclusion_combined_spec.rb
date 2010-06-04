require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Aspect4r do
  it "inherit aspects from parent class which include aspects from module" do
    module Mod
      include Aspect4r
      
      def test
        @value << "test"
      end
      
      around :test do |proxy|
        @value << "around1"
        a4r_invoke proxy
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
    end
    
    
    o = child.new
    o.test
    
    o.value.should == %w(before around1 test around2 after)
  end
  
  it "advices in parent class and included modules" do
    module Mod3
      include Aspect4r
      
      def test
        @value << "test(module)"
      end
      
      around :test do |proxy|
        @value << "around1"
        a4r_invoke proxy
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
      
      def test
        @value << "test(parent)"
      end
    end
    
    class Child3 < Parent3
      include Mod3
    end
    
    
    o = Child3.new
    o.test
    
    o.value.should == %w(before(module) around1 test(module) around2 after)
  end
end
