require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

module Aspect4r::Model
  describe Advice do
    it "before? returns true for before advice" do
      advice = Advice.new Advice::BEFORE, MethodMatcher.new, :advice_method, :group
      advice.before?.should be_true
    end
  
    it "before_filter? returns false for before_filter advice" do
      advice = Advice.new Advice::BEFORE, MethodMatcher.new, :advice_method, :group
      advice.before_filter?.should be_false
    end
  
    it "before? returns false for before advice" do
      advice = Advice.new Advice::BEFORE, MethodMatcher.new, :advice_method, :group, :skip_if_false => true
      advice.before?.should be_false
    end
  
    it "before_filter? returns true for before_filter advice" do
      advice = Advice.new Advice::BEFORE, MethodMatcher.new, :advice_method, :group, :skip_if_false => true
      advice.before_filter?.should be_true
    end
  
    it "invoke before advice" do
      advice = Advice.new Advice::BEFORE, MethodMatcher.new, :advice_method, :group
    
      o = Object.new
      o.class.send :define_method, :advice_method do |*args|
        do_something *args
      end
    
      o.expects(:do_something).with(1)
    
      advice.invoke(o, 1)
    end
  
    it "invoke after advice" do
      advice = Advice.new Advice::AFTER, MethodMatcher.new, :advice_method, :group
    
      o = Object.new
      o.class.send :define_method, :advice_method do |result, *args|
        do_something result, *args
      end
    
      o.expects(:do_something).with(1)
    
      advice.invoke(o, 1)
    end
  
    it "invoke around advice" do
      advice = Advice.new Advice::AROUND, MethodMatcher.new, :advice_method, :group
    
      o = Object.new
      o.class.send :define_method, :advice_method do |proxy, *args|
        a4r_invoke proxy, *args
      end
    
      o.expects(:a4r_invoke).with(:proxy, 1)
    
      advice.invoke(o, :proxy, 1)
    end
  end
end