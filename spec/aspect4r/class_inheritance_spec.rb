require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Aspect4r do
  it "basic inheritance should work" do
    class Parent
      include Aspect4r
      
      attr :value
      
      def initialize
        @value = []
      end
      
      def test
        @value << "test"
      end
      
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
    
    class Child < Parent
    end
    
    o = Child.new
    o.test
    
    o.value.should == %w(before around1 test around2 after)
  end
  
  it "aspects in body and inherited aspects can be combined" do
    class Parent2
      include Aspect4r
      
      attr :value
      
      def initialize
        @value = []
      end
      
      def test
        @value << "test"
      end
      
      before_method :test do
        @value << "before"
      end
      
      after_method :test do |result|
        @value << "after"
      end
    end
    
    class Child2 < Parent2
      include Aspect4r
      
      around_method :test do |proxy_method|
        @value << "around1"
        send proxy_method
        @value << "around2"
      end
    end
    
    o = Child2.new
    o.test
    
    o.value.should == %w(before around1 test around2 after)
  end
end
