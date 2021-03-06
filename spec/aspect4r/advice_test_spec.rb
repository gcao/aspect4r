require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Test Advices" do
  before do
    @klass = Class.new do
      include Aspect4r
      
      attr :value
      
      def initialize
        @value = []
      end
      
      around :test do |input, &block|
        @value << "around(before)"
        block.call input
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
    @klass.a4r_data.advices_for_method(:test).size.should == 4
  end

  it "around advice" do
    advice = @klass.a4r_data.advices_for_method(:test)[0]
    advice.around?.should be true

    o = @klass.new
     
    advice.invoke(o, 1) {}

    o.value.should == %w(around(before) around(after))
  end
  
  it "before advice" do
    advice = @klass.a4r_data.advices_for_method(:test)[1]
    advice.before?.should be true

    o = @klass.new
    advice.invoke(o, 1)

    o.value.should == %w(before)
  end
  
  it "before_filter advice returns true if input is not negative" do
    advice = @klass.a4r_data.advices_for_method(:test)[2]
    advice.before_filter?.should be true

    o = @klass.new
    advice.invoke(o, 1).should be true

    o.value.should == %w(before_filter)
  end
  
  it "before_filter advice returns false if input is negative" do
    advice = @klass.a4r_data.advices_for_method(:test)[2]

    o = @klass.new
    advice.invoke(o, -1).should be false
  end
  
  it "after advice" do
    advice = @klass.a4r_data.advices_for_method(:test)[3]
    advice.after?.should be true

    o = @klass.new
    advice.invoke(o, 1, 1).should == 100

    o.value.should == %w(after)
  end
  
  it "test method without advices" do
    @klass.a4r_disable_advices_temporarily :test do
      o = @klass.new
      o.test 1
      
      o.value.should == %w(test)
    end
  end
end
