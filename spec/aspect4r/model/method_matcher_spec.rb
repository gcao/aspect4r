require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

module Aspect4r
  module Model
    describe MethodMatcher do
      it "should match String" do
        MethodMatcher.new('test').match?('test').should_not be_nil
      end
      
      it "should match Symbol" do
        MethodMatcher.new(:test).match?('test').should_not be_nil
      end
      
      it "should match regular expression" do
        MethodMatcher.new(/test/).match?('test').should_not be_nil
      end
      
      it "should return true if any item matches" do
        MethodMatcher.new(:test1, :test2).match?('test2').should_not be_nil
      end
      
      it "should return nil if none matches" do
        MethodMatcher.new(:test1, :test2).match?('test3').should be_nil
      end
    end
  end
end