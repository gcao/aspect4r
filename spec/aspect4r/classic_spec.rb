require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'aspect4r/classic'

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

      around_method :test do |proxy|
        @value << "around1"
        proxy.bind(self).call
        @value << "around2"
      end
      
      before_method :test do
        @value << "before"
      end
      
      before_method_filter :test do
        @value << "before_filter"
      end
      
      after_method :test do |result|
        @value << "after"
      end
    end
    
    o = klass.new
    o.test
    
    o.value.should == %w(before before_filter around1 test around2 after)
  end
end
