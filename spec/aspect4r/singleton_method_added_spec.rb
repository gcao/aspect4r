require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "singleton_method_added" do
  it "should work if target method is defined after singleton_method_added and singleton_method_added calls super" do
    class AdvicesOnClassMethod1
      include Aspect4r
        
      def self.singleton_method_added(method)
        super
      end
      
      class << self
        
        def value
          @value ||= []
        end
  
        around :test do |&block|
          value << "around1"
          block.call
          value << "around2"
        end   
      
        before :test do
          value << "before"
        end
  
        after :test do |result|
          value << "after"
        end
      
        def test
          value << "test"
        end
      end
    end
    
    AdvicesOnClassMethod1.test
    AdvicesOnClassMethod1.value.should == %w(before around1 test around2 after)
  end
end
