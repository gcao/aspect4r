require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Aspect4r execution order" do
  before do
    @klass = Class.new do
      include Aspect4r
      
      attr :value
      
      def initialize
        @value = []
      end
      
      def test
        @value << "test"
      end
    end
  end
  
  it "should be correct" do
    @klass.class_eval do
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
    
    o = @klass.new
    o.test
    
    o.value.should == %w(before around1 test around2 after)
  end
  
  it "should be correct when there are 2 of each" do
    @klass.class_eval do
      before_method :test do
        @value << "before1"
      end
      
      before_method :test do
        @value << "before2"
      end
      
      after_method :test do |result|
        @value << "after1"
      end
      
      after_method :test do
        @value << "after2"
      end
      
      around_method :test do |proxy_method|
        @value << "around11"
        send proxy_method
        @value << "around12"
      end
      
      around_method :test do |proxy_method|
        @value << "around21"
        send proxy_method
        @value << "around22"
      end
    end
    
    o = @klass.new
    o.test
    
    o.value.should == %w(before1 before2 around11 around21 test around22 around12 after1 after2)
  end
end

describe "Aspect4r result handling" do
  it "should return correct result" do
    @klass = Class.new do
      include Aspect4r
      
      def test
        "test"
      end

      after_method :test do |result|
        result + " after"
      end
      
      around_method :test do |proxy_method|
        result = send proxy_method
        "around1 #{result} around2"
      end
    end
    
    o = @klass.new
    o.test.should == "around1 test around2 after"
  end
end

describe "Include aspects from module" do
  before do
    @klass = Class.new do
      attr :value
      
      def initialize
        @value = []
      end
      
      def test
        @value << "test"
      end
    end
  end
  
  it "should work with aspects defined in a module" do
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

    @klass.send :alias_method, Aspect4r::Helper.backup_method_name(:test), :test
    @klass.send :include, Aspect4r
    @klass.send :include, mod
    
    Aspect4r::Helper.create_method @klass, :test, mod.a4r_definitions[:test]

    o = @klass.new
    o.test
    
    o.value.should == %w(before around1 test around2 after)
  end
end

describe "Mix aspects from module" do
  it "basic mix" do
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
  
  it "should work with aspects defined in a module" do
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
