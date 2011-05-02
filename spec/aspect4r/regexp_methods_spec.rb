require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Advices matched by regular expression" do
  it "should not apply to methods defined before advice" do
    @klass = Class.new do
      include Aspect4r

      attr :value
      
      def initialize
        @value = []
      end
      
      def test
        @value << "test"
      end
      
      before /test/ do
        @value << "before"
      end
    end

    @klass.new.test.should == %w"test"
  end
  
  it "should not apply to methods defined after advice" do
    @klass = Class.new do
      include Aspect4r

      attr :value
      
      def initialize
        @value = []
      end
      
      before /test/ do
        @value << "before"
      end
      
      def test
        @value << "test"
      end
    end

    @klass.new.test.should == %w"before test"
  end
end