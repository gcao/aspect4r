require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Advice on class method" do
  it "method before advices" do
    pending
    klass = Class.new do
      include Aspect4r
      
      def self.value
        @value ||= []
      end
      
      def self.test input
        value << "test"
      end
      
      around 'self.test' do |proxy, input|
        value << "around(before)"
        a4r_invoke proxy, input
        value << "around(after)"
      end
      
      before 'self.test' do |input|
        value << "before"
      end
      
      after 'self.test' do |result, input|
        value << "after"
        result
      end
    end
    
    klass.test 1
    
    klass.value.should == %w(before around(before) test around(after) after)
  end
  
  it "method after advices" do
    pending
    klass = Class.new do
      include Aspect4r
      
      def self.value
        @value ||= []
      end
      
      around 'self.test' do |proxy, input|
        value << "around(before)"
        a4r_invoke proxy, input
        value << "around(after)"
      end
      
      before 'self.test' do |input|
        value << "before"
      end
      
      after 'self.test' do |result, input|
        value << "after"
        result
      end
      
      def self.test input
        value << "test"
      end
    end
    
    klass.test 1
    
    klass.value.should == %w(before around(before) test around(after) after)
  end
end
