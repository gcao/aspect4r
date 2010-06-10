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
      
      before :test, :name => 'before_advice' do |input|
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
  
  it "number of advices" do
    @klass.a4r_data[:test].size.should == 4
  end

  it "around advice" do
    advice = @klass.a4r_data[:test][0]
    advice.around?.should be_true

    o = @klass.new
    o.expects(:a4r_invoke).with(:proxy, 1)
     
    advice.invoke(o, :proxy, 1)

    o.value.should == %w(around(before) around(after))
  end
  
  it "before advice" do
    advice = @klass.a4r_data[:test][1]
    advice.before?.should be_true

    o = @klass.new
    advice.invoke(o, 1)

    o.value.should == %w(before)
  end
  
  it "before advice retrieved by name" do
    advice = @klass.a4r_data[:test][:before_advice]
    advice.before?.should be_true

    o = @klass.new
    advice.invoke(o, 1)

    o.value.should == %w(before)
  end
  
  it "before_filter advice returns true if input is not negative" do
    advice = @klass.a4r_data[:test][2]
    advice.before_filter?.should be_true

    o = @klass.new
    advice.invoke(o, 1).should be_true

    o.value.should == %w(before_filter)
  end
  
  it "before_filter advice returns false if input is negative" do
    advice = @klass.a4r_data[:test][2]

    o = @klass.new
    advice.invoke(o, -1).should be_false
  end
  
  it "after advice" do
    advice = @klass.a4r_data[:test][3]
    advice.after?.should be_true

    o = @klass.new
    advice.invoke(o, 1, 1).should == 100

    o.value.should == %w(after)
  end
end
