require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "super in method body" do
  it "advice in child class and no advice in parent class" do
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
  
  it "no advice in child class and advice in parent class" do
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
  
  it "advices in grand parent and parent and self" do
    grand_parent = Class.new do
      include Aspect4r
      
      before :test do
        @value << "before(grand_parent)"
      end
      
      def test
        @value << "test(grand_parent)"
      end
    end
    
    parent = Class.new(grand_parent) do
      include Aspect4r
      
      before :test do
        @value << "before(parent)"
      end
      
      def test
        super
        @value << "test(parent)"
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
        @value << "test"
      end
    end
    
    o = klass.new
    o.test
    
    o.value.should == %w(before before(parent) before(grand_parent) test(grand_parent) test(parent) test)
  end
end