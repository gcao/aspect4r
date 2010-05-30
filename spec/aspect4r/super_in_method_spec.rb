require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "super in method body" do
  it "advice in child class" do
    parent = Class.new do
      def test
        @value << "parent"
      end
    end
    
    klass = Class.new(parent) do
      include Aspect4r
      
      attr :value
      
      def initialize
        @value = []
      end
      
      before :test do
        @value << "before"
      end
      
      def test
        super
        @value << "self"
      end
    end
    
    o = klass.new
    o.test
    
    o.value.should == %w(before parent self)
  end
  
  it "advice in parent class" do
    parent = Class.new do
      include Aspect4r
      
      before :test do
        @value << "before"
      end
      
      def test
        @value << "parent"
      end
    end
    
    klass = Class.new(parent) do
      attr :value
      
      def initialize
        @value = []
      end
      
      def test
        super
        @value << "self"
      end
    end
    
    o = klass.new
    o.test
    
    o.value.should == %w(before parent self)
  end
  
  it "grand parent + parent + self" do
    grand_parent = Class.new do
      def test
        @value << "grand_parent"
      end
    end
    
    parent = Class.new(grand_parent) do
      def test
        super
        @value << "parent"
      end
    end
    
    klass = Class.new(parent) do
      include Aspect4r
      
      attr :value
      
      def initialize
        @value = []
      end
      
      before :test do
        @value << "before"
      end
      
      def test
        super
        @value << "self"
      end
    end
    
    o = klass.new
    o.test
    
    o.value.should == %w(before grand_parent parent self)
  end
end