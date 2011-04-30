require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'aspect4r'

describe Aspect4r::Classic do
  it "should work" do
    klass = Class.new do
      include Aspect4r::Classic
      
      attr :value
      
      def initialize
        @value = []
      end
      
      def test
        @value << "test"
      end

      a4r_around :test do |&block|
        @value << "around1"
        block.call
        @value << "around2"
      end
      
      a4r_before :test do
        @value << "before"
      end
      
      a4r_before_filter :test do
        @value << "before_filter"
      end
      
      a4r_after :test do |result|
        @value << "after"
      end
    end
    
    o = klass.new
    o.test
    
    o.value.should == %w(before before_filter around1 test around2 after)
  end
end
