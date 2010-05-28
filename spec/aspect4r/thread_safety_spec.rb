require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Aspect4r do
  it "should be thread safe after initialization" do
    pending "HOW DO WE TEST THIS?"
    
    klass = Class.new do
      def test
      end
      
      before_method :test do
      end
    end
  end
end
