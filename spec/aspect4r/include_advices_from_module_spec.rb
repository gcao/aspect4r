require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Aspect4r do
  it "Mix advices from module" do
    module AdvicesMod
      include Aspect4r
      
      def before_test
        @value << "before(module)"
      end
      
      def self.included(base)
        super

        base.send :include, Aspect4r
        base.before :test, :before_test
      end
    end
    
    klass = Class.new do
      include Aspect4r
      
      attr :value
      
      def initialize
        @value = []
      end
      
      before :test do
        @value << 'before'
      end
      
      def test
        @value << 'test'
      end
      
      include AdvicesMod
    end
    
    o = klass.new
    o.test
    
    o.value.should == %w(before before(module) test)
  end
  
  it "Mix advice group from module" do
    module AdvicesMod1
      include Aspect4r
      
      def before_test
        @value << "before(module)"
      end
      
      def self.included(base)
        super
        
        base.send :include, Aspect4r
        base.a4r_group do
          before :test, :before_test
        end
      end
    end
    
    klass = Class.new do
      include Aspect4r
      
      attr :value
      
      def initialize
        @value = []
      end
      
      before :test do
        @value << 'before'
      end
      
      def test
        @value << 'test'
      end
      
      include AdvicesMod1
    end
    
    o = klass.new
    o.test
    
    o.value.should == %w(before(module) before test)
  end
end
