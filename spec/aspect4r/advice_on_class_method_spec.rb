require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Advice on class method" do
  it "method before advices" do
    klass = Class.new do
      class << self
        include Aspect4r
        
        def value
          @value ||= []
        end
        
        def test input
          value << "test"
        end
        
        around :test do |proxy, input|
          value << "around(before)"
          a4r_invoke proxy, input
          value << "around(after)"
        end
        
        before :test do |input|
          value << "before"
        end
        
        after :test do |result, input|
          value << "after"
          result
        end
      end
    end
    
    klass.test 1
    
    klass.value.should == %w(before around(before) test around(after) after)
  end
  
  it "method after advices" do
    pending "Need to think about how to handle advices for class methods, one way is to add 'self.' to advised method name and handle it differently"
    klass = Class.new do
      class << self
        include Aspect4r
        
        def value
          @value ||= []
        end
        
        around :test do |proxy, input|
          value << "around(before)"
          a4r_invoke proxy, input
          value << "around(after)"
        end
        
        before :test do |input|
          value << "before"
        end
        
        after :test do |result, input|
          value << "after"
          result
        end
        
        def test input
          value << "test"
        end
      end
    end
    
    klass.test 1
    
    klass.value.should == %w(before around(before) test around(after) after)
  end
end
