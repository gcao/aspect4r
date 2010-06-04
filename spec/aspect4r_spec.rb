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
  
  it "around + before + after" do
    @klass.class_eval do
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
    
    o = @klass.new
    o.test
    
    o.value.should == %w(before around1 test around2 after)
  end
  
  it "before + after + around" do
    @klass.class_eval do
      
      before :test do
        @value << "before"
      end
      
      after :test do |result|
        @value << "after"
      end
      
      around :test do |proxy|
        @value << "around1"
        a4r_invoke proxy
        @value << "around2"
      end
    end
    
    o = @klass.new
    o.test
    
    o.value.should == %w(around1 before test after around2)
  end
  
  it "2 around + 2 before + 2 after" do
    @klass.class_eval do
      around :test do |proxy|
        @value << "around11"
        a4r_invoke proxy
        @value << "around12"
      end
      
      around :test do |proxy|
        @value << "around21"
        a4r_invoke proxy
        @value << "around22"
      end
      
      before :test do
        @value << "before1"
      end
      
      before :test do
        @value << "before2"
      end
      
      after :test do |result|
        @value << "after1"
      end
      
      after :test do
        @value << "after2"
      end
    end
    
    o = @klass.new
    o.test
    
    o.value.should == %w(before1 before2 around21 around11 test around12 around22 after1 after2)
  end
  
  it "before + after + around + before + after" do
    @klass.class_eval do
      before :test do
        @value << "before1"
      end
      
      after :test do |result|
        @value << "after1"
      end
      
      around :test do |proxy|
        @value << "around1"
        a4r_invoke proxy
        @value << "around2"
      end
      
      before :test do
        @value << "before2"
      end
      
      after :test do |result|
        @value << "after2"
      end
    end
    
    o = @klass.new
    o.test
    
    o.value.should == %w(before2 around1 before1 test after1 around2 after2)
  end
end

describe "Aspect4r result handling" do
  it "should return correct result" do
    @klass = Class.new do
      include Aspect4r
      
      def test
        "test"
      end
      
      around :test do |proxy|
        result = a4r_invoke proxy
        "around1 #{result} around2"
      end

      after :test do |result|
        result + " after"
      end
    end
    
    o = @klass.new
    o.test.should == "around1 test around2 after"
  end
end

describe "Aspect4r chaining" do
  it "execution order" do
    @klass = Class.new do
      include Aspect4r
      
      attr :value
      
      def initialize
        @value = []
      end
      
      def test
        @value << "test"
      end
      
      def do_something
        @value << "do_something"
      end
      
      def process_result result
        @value << "process_result"
      end
      
      around :test do |proxy|
        @value << "around11"
        a4r_invoke proxy
        @value << "around12"
      end
      
      before :test do
        @value << "before1"
      end
      
      before :test, :do_something
      
      before :do_something do
        @value << "before(do_something)"
      end
      
      after :do_something do
        @value << "after(do_something)"
      end
      
      after :test do |result|
        @value << "after1"
      end
      
      after :test, :process_result
      
      before :process_result do
        @value << "before(process_result)"
      end
      
      after :process_result do
        @value << "after(process_result)"
      end
    end
      
    o = @klass.new
    o.test
    
    o.value.should == %w(before1 before(do_something) do_something after(do_something) 
                         around11 test around12 
                         after1 before(process_result) process_result after(process_result))
  end
end
