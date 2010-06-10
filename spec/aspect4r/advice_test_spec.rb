require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Test Advices" do
  before do
    @klass = Class.new do
      include Aspect4r
      
      attr :value
      
      def initialize
        @value = []
      end
      
      around :test do |proxy, input|
        @value << "around(before)"
        a4r_invoke proxy, input
        @value << "around(after)"
      end
      
      before :test do |input|
        @value << 'before'
      end
      
      before_filter :test do |input|
        @value << 'before_filter'
        input >= 0
      end
      
      after :test do |result, input|
        @value << "after"
        result * 100
      end
      
      def test input
        @value << "test"
      end
    end
  end
  
  it "Verify advices" do
    @klass.a4r_data[:test].advices.size.should == 4
  end
  
  it "around advice" do
    advice = @klass.a4r_data[:test].advices[0]
    advice.around?.should be_true

    o = @klass.new
    o.expects(:a4r_invoke).with(nil, 1)
     
    advice.invoke(o, nil, 1)

    o.value.should == %w(around(before) around(after))
  end
  
  it "before advice" do
    advice = @klass.a4r_data[:test].advices[1]
    advice.before?.should be_true

    o = @klass.new
    advice.invoke(o, 1)

    o.value.should == %w(before)
  end
  
  it "before_filter advice" do
    advice = @klass.a4r_data[:test].advices[2]
    advice.before_filter?.should be_true

    o = @klass.new
    advice.invoke(o, 1).should be_true

    o.value.should == %w(before_filter)
  end
  
  it "before_filter advice returns false" do
    advice = @klass.a4r_data[:test].advices[2]

    o = @klass.new
    advice.invoke(o, -1).should be_false
  end
  
  it "after advice" do
    advice = @klass.a4r_data[:test].advices[3]
    advice.after?.should be_true

    o = @klass.new
    advice.invoke(o, 1, 1).should == 100

    o.value.should == %w(after)
  end
end
