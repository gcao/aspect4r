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
    
    o.value.should == %w(before around1 test around2 after)
  end
  
  it "override" do
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
  
  it "override + super" do
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

  it "include module with aspects then add aspects in body" do
    module AspectMod
      include Aspect4r
      
      def test
        @value << "test(module)"
      end
  
      around :test do |proxy|
        @value << "around1"
        send proxy
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
  
  it "double inclusion" do
    module AspectMod1
      include Aspect4r
      
      before :test do
        @value << "before"
      end
    end
    
    class ParentClass
      include AspectMod1
      
      attr :value
      
      def initialize
        @value = []
      end
      
      def test
        @value << "test"
      end
    end
    
    class ChildClass < ParentClass
      include AspectMod1
    end
    
    o = ChildClass.new
    o.test
    
    o.value.should == %w(test) 
  end
  
  it "define aspects in body then include module with aspects" do
    class AspectMix2
      include Aspect4r

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
    
    mod = Module.new do
      include Aspect4r
  
      around :test do |proxy|
        @value << "around1"
        send proxy
        @value << "around2"
      end
      
      after :test do |result|
        @value << "after"
      end
    end

    AspectMix2.send :include, mod

    o = AspectMix2.new
    o.test
    
    o.value.should == %w(before test)
  end

  it "before in body and in module" do
    module AspectMod3
      include Aspect4r
      
      before :test do
        @value << "before(module)"
      end
    end
    
    class AspectMix3
      include Aspect4r
      include AspectMod3

      attr :value
      
      def initialize
        @value = []
      end
      
      def test
        @value << "test"
      end
      
      before :test do
        @value << "before(body)"
      end
    end

    o = AspectMix3.new
    o.test
    
    o.value.should == %w(before(body) test)
  end
  
  it "after in body and in module" do
    module AspectMod4
      include Aspect4r
      
      after :test do |result|
        @value << "after(module)"
      end
    end
    
    class AspectMix4
      include Aspect4r
      include AspectMod4

      attr :value
      
      def initialize
        @value = []
      end
      
      def test
        @value << "test"
      end
      
      after :test do
        @value << "after(body)"
      end
    end

    o = AspectMix4.new
    o.test
    
    o.value.should == %w(test after(body))
  end
end
