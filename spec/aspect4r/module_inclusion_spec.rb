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
      
      before_method :test do
        @value << "before"
      end
  
      after_method :test do |result|
        @value << "after"
      end
  
      around_method :test do |proxy_method|
        @value << "around1"
        send proxy_method
        @value << "around2"
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
      
      after_method :test do |result|
        @value << "after"
      end
  
      around_method :test do |proxy_method|
        @value << "around1"
        send proxy_method
        @value << "around2"
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
      
      after_method :test do |result|
        @value << "after"
      end
  
      around_method :test do |proxy_method|
        @value << "around1"
        send proxy_method
        @value << "around2"
      end   
    end

    AspectMix2.send :include, mod

    o = AspectMix2.new
    o.test
    
    o.value.should == %w(before around1 test around2 after)
  end
end
