require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Aspect4r::Helper do
  describe "self.find_available_name" do
    it "should return test0 as first available method" do
      Aspect4r::Helper.find_available_method_name(Class.new, "test").should =~ /test0/
    end

    it "should return test1 if find_available_method_name is called once already" do
      klass = Class.new
      klass.class_eval do
        first = Aspect4r::Helper.find_available_method_name(klass, "test")

        define_method first do end

        private first
      end
      Aspect4r::Helper.find_available_method_name(klass, "test").should =~ /test1/
    end
  end

  describe "self.create_method" do
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

        def before_test
          @value << "before_test"
        end

        def after_test result
          @value << "after_test"
          result
        end

        def around_test
          @value << "around_test_before"
          result = yield
          @value << "around_test_after"
          result
        end
      end
    end

    it "No advice" do
      Aspect4r::Helper.create_method @klass, :test

      o = @klass.new
      o.test

      o.value.should == %w(test)
    end

    it "before advices" do
      @klass.before :test, :before_test
      Aspect4r::Helper.create_method @klass, :test

      o = @klass.new
      o.test

      o.value.should == %w(before_test test)
    end

    it "after advices" do
      @klass.after :test, :after_test
      Aspect4r::Helper.create_method @klass, :test

      o = @klass.new
      o.test

      o.value.should == %w(test after_test)
    end

    it "around advices" do
      @klass.around :test, :around_test
      Aspect4r::Helper.create_method @klass, :test

      o = @klass.new
      o.test

      o.value.should == %w(around_test_before test around_test_after)
    end

    it "before + after advices" do
      @klass.before :test, :before_test
      @klass.after :test, :after_test
      Aspect4r::Helper.create_method @klass, :test

      o = @klass.new
      o.test

      o.value.should == %w(before_test test after_test)
    end

    it "around + before + after advices" do
      @klass.around :test, :around_test
      @klass.before :test, :before_test
      @klass.after :test, :after_test
      Aspect4r::Helper.create_method @klass, :test

      o = @klass.new
      o.test

      o.value.should == %w(before_test around_test_before test around_test_after after_test)
    end
  end
end
