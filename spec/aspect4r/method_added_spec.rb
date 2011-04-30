require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "method_added" do
  it "should work if target method is defined after method_added and method_added calls super" do
    klass = Class.new do
      include Aspect4r
      
      attr :value
      
      def initialize
        @value = []
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
      
      def self.method_added(method)
        super
      end
      
      def test
        @value << "test"
      end
    end
    
    o = klass.new
    o.test
    
    o.value.should == %w(before around1 test around2 after)
  end
end
