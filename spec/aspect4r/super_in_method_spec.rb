require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "super in method body" do
  it "basic" do
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
      
      def test
        super
        @value << "self"
      end
      
      before :test do
        @value << "before"
      end
    end
    
    o = klass.new
    o.test
    
    o.value.should == %w(before parent self)
  end
end