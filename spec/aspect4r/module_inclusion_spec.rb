require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Aspect4r do
  it "basic module inclusion should work" do
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
  
      around_method :test do |proxy_method|
        @value << "around1"
        send proxy_method
        @value << "around2"
      end   
      
      before_method :test do
        @value << "before"
      end
  
      after_method :test do |result|
        @value << "after"
      end
    end

    klass.send :alias_method, Aspect4r::Helper.backup_method_name(:test), :test
    klass.send :include, Aspect4r
    klass.send :include, mod
    
    Aspect4r::Helper.create_method klass, :test, mod.a4r_definitions[:test]

    o = klass.new
    o.test
    
    o.value.should == %w(before around1 test around2 after)
  end

  it "include module with aspects then add aspects in body" do
    module AspectMod
      include Aspect4r
  
      around_method :test do |proxy_method|
        @value << "around1"
        send proxy_method
        @value << "around2"
      end
      
      after_method :test do |result|
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
      
      def test_without_a4r
        @value << "test"
      end
      
      before_method :test do
        @value << "before"
      end
    end

    o = AspectMix.new
    o.test
    
    o.value.should == %w(before around1 test around2 after)
  end
  
  it "double inclusion" do
    module AspectMod1
      include Aspect4r
      
      before_method :test do
        @value << "before"
      end
    end
    
    class ParentClass
      include AspectMod1
      
      attr :value
      
      def initialize
        @value = []
      end
      
      def test_without_a4r
        @value << "test"
      end
    end
    
    class ChildClass < ParentClass
      include AspectMod1
    end
    
    o = ChildClass.new
    o.test
    
    o.value.should == %w(before test) 
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
      
      before_method :test do
        @value << "before"
      end
    end
    
    mod = Module.new do
      include Aspect4r
  
      around_method :test do |proxy_method|
        @value << "around1"
        send proxy_method
        @value << "around2"
      end
      
      after_method :test do |result|
        @value << "after"
      end
    end

    AspectMix2.send :include, mod

    o = AspectMix2.new
    o.test
    
    o.value.should == %w(around1 before test around2 after)
  end

  it "before in body and in module" do
    module AspectMod3
      include Aspect4r
      
      before_method :test do
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
      
      def test_without_a4r
        @value << "test"
      end
      
      before_method :test do
        @value << "before(body)"
      end
    end

    o = AspectMix3.new
    o.test
    
    o.value.should == %w(before(body) before(module) test)
  end
  
  it "after in body and in module" do
    module AspectMod4
      include Aspect4r
      
      after_method :test do |result|
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
      
      def test_without_a4r
        @value << "test"
      end
      
      after_method :test do
        @value << "after(body)"
      end
    end

    o = AspectMix4.new
    o.test
    
    o.value.should == %w(test after(module) after(body))
  end
  
  it "attach module after both class and module is defined" do
    module AspectMod5
      include Aspect4r
      
      before_method :test do
        @value << "before1"
      end
      
      before_method :test do
        @value << "before2"
      end
    end
    
    class AspectMix5
      attr :value
      
      def initialize
        @value = []
      end
      
      def test
        @value << "test"
      end
      
      include AspectMod5
    end

    o = AspectMix5.new
    o.test
    
    o.value.should == %w(before1 before2 test)
  end
end
