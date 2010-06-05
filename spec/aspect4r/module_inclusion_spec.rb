require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Aspect4r do
  it "basic module inclusion should work" do
    klass = Class.new do
      attr :value
      
      def initialize
        @value = []
      end
    end
    
    mod = Module.new do
      include Aspect4r
      
      def test
        @value << "test"
      end
  
      around :test do |proxy|
        @value << "around1"
        a4r_invoke proxy
        @value << "around2"
      end   
      
      before :test do
        @value << "before"
      end
  
      after :test do |result|
        @value << "after"
      end
    end

    klass.send :include, mod
    
    o = klass.new
    o.test
    
    o.value.should == %w(before around1 test around2 after)
  end
  
  it "override method" do
    klass = Class.new do
      attr :value
      
      def initialize
        @value = []
      end
      
      def test
        @value << "test"
      end
    end
    
    mod = Module.new do
      include Aspect4r
      
      def test
        @value << "test(module)"
      end
  
      around :test do |proxy|
        @value << "around1"
        send proxy
        @value << "around2"
      end   
      
      before :test do
        @value << "before"
      end
  
      after :test do |result|
        @value << "after"
      end
    end

    klass.send :include, mod
    
    o = klass.new
    o.test
    
    o.value.should == %w(test)
  end
  
  it "override method and call super" do
    klass = Class.new do
      attr :value
      
      def initialize
        @value = []
      end
      
      def test
        super
        @value << "test"
      end
    end
    
    mod = Module.new do
      include Aspect4r
      
      def test
        @value << "test(module)"
      end   
      
      before :test do
        @value << "before"
      end
    end

    klass.send :include, mod
    
    o = klass.new
    o.test
    
    o.value.should == %w(before test(module) test)
  end

  it "method+advices in child class and method+advices in module" do
    module AspectMod
      include Aspect4r
      
      def test
        @value << "test(module)"
      end
  
      around :test do |proxy|
        @value << "around1"
        a4r_invoke proxy
        @value << "around2"
      end
      
      after :test do |result|
        @value << "after"
      end
    end
    
    class AspectMix
      include Aspect4r
      include AspectMod

      attr :value
      
      def initialize
        @value = []
      end
      
      def test
        @value << "test"
      end
      
      before :test do
        @value << "before"
      end
    end

    o = AspectMix.new
    o.test
    
    o.value.should == %w(before test)
  end

  it "method+advices in child class and method+advices in module and call super" do
    module AspectMod1
      include Aspect4r
      
      def test
        @value << "test(module)"
      end
  
      around :test do |proxy|
        @value << "around1"
        a4r_invoke proxy
        @value << "around2"
      end
      
      after :test do |result|
        @value << "after"
      end
    end
    
    class AspectMix1
      include Aspect4r
      include AspectMod1

      attr :value
      
      def initialize
        @value = []
      end
      
      def test
        super
        @value << "test"
      end
      
      before :test do
        @value << "before"
      end
    end

    o = AspectMix1.new
    o.test
    
    o.value.should == %w(before around1 test(module) around2 after test)
  end
end
