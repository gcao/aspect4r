require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Group of advices" do
  it "should work" do
    klass = Class.new do
      include Aspect4r

      attr :value
      
      def initialize
        @value = []
      end
      
      def test
        @value << "test"
      end

      a4r_group do
        before :test do
          @value << "before(group1)"
        end
      end
      
      a4r_group do
        before :test do
          @value << "before(group2)"
        end
      end
    end
    
    o = klass.new
    o.test
    
    o.value.should == %w(before(group2) before(group1) test)
  end
end
