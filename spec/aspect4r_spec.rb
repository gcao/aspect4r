require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Mixing regular expressions and string" do
  it "should work" do
    @klass = Class.new do
      include Aspect4r
      
      before /do_/, "test" do
        @value << "before"
      end
      
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
    end
    
    o = @klass.new
    o.test
    
    o.value.should == %w(before test)
    
    o = @klass.new
    o.do_something
    
    o.value.should == %w(before do_something)
  end
end

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
      around :test do |&block|
        @value << "around1"
        block.call
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
      
      around :test do |&block|
        @value << "around1"
        block.call
        @value << "around2"
      end
    end
    
    o = @klass.new
    o.test
    
    o.value.should == %w(around1 before test after around2)
  end
  
  it "2 around + 2 before + 2 after" do
    @klass.class_eval do
      around :test do |&block|
        @value << "around11"
        block.call
        @value << "around12"
      end
      
      around :test do |&block|
        @value << "around21"
        block.call
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
      
      after :test do |result|
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
      
      around :test do |&block|
        @value << "around1"
        block.call
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
      
      around :test do |&block|
        result = block.call
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

describe "Aspect4r chaining (add advice to advice method)" do
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
      
      around :test do |&block|
        @value << "around11"
        block.call
        @value << "around12"
      end
      
      before :test do
        @value << "before1"
      end
      
      before :test, :do_something
      
      before :do_something do
        @value << "before(do_something)"
      end
      
      after :do_something do |result|
        @value << "after(do_something)"
      end
      
      after :test do |result|
        @value << "after1"
      end
      
      after :test, :process_result
      
      before :process_result do |result|
        @value << "before(process_result)"
      end
      
      after :process_result do |result, *args|
        @value << "after(process_result)"
      end
    end
      
    o = @klass.new
    o.test
    
    o.value.should == %w(before1 before(do_something) do_something after(do_something) 
                         around11 test around12 
                         after1 before(process_result) process_result after(process_result))
  end

  it "should return correct result (after advice on advices)" do
    @klass = Class.new do
      include Aspect4r
      
      def test
        "test"
      end
      
      def around_test
        result = yield
        "around1 #{result} around2"
      end
      
      def after_test result
        result + " after_test"
      end
      
      around :test, :around_test
      
      after :test, :after_test
      
      after :after_test do |result, *args|
        result + " after(after_test)"
      end
      
      after :around_test do |result, *args|
        result + " after(around_test)"
      end
    end
    
    o = @klass.new
    o.test.should == "around1 test around2 after(around_test) after_test after(after_test)"
  end
  
  it "should return correct result (around advice on advices)" do
    @klass = Class.new do
      include Aspect4r
      
      def test
        "test"
      end
      
      def around_test
        result = yield
        "around1 #{result} around2"
      end
      
      def after_test result
        result + " after_test"
      end
      
      around :test, :around_test
      
      after :test, :after_test
      
      around :after_test do |*args, &block|
        result = block.call *args
        "around1(after_test) " + result + " around2(after_test)"
      end
      
      around :around_test do |*args, &block|
        result = block.call *args
        "around1(around_test) " + result + " around2(around_test)"
      end
    end
    
    o = @klass.new
    o.test.should == "around1(after_test) around1(around_test) around1 test around2 around2(around_test) after_test around2(after_test)"
  end
end
