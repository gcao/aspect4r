require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Advices on singleton method (also known as class method)" do
  it "class method" do
    class AdvicesOnClassMethod
      include Aspect4r

      class << self

        def value
          @value ||= []
        end
        
        around :test do |proxy|
          value << "around(before)"
          a4r_invoke proxy
          value << "around(after)"
        end
        
        before :test do
          value << "before"
        end
        
        after :test do
          value << "after"
        end
        
        def test
          value << "test"
        end
      end
    end
    
    AdvicesOnClassMethod.test
    AdvicesOnClassMethod.value.should == %w(before around(before) test around(after) after)
  end

  it "module singleton method" do
    module AdvicesOnModuleSingletonMethod
      include Aspect4r

      class << self
 
        def value
          @value ||= []
        end
        
        around :test do |proxy|
          value << "around(before)"
          a4r_invoke proxy
          value << "around(after)"
        end
        
        before :test do
          value << "before"
        end
        
        after :test do
          value << "after"
        end
        
        def test
          value << "test"
        end
      end
    end
    
    AdvicesOnModuleSingletonMethod.test
    AdvicesOnModuleSingletonMethod.value.should == %w(before around(before) test around(after) after)
  end
end
