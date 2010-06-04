require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class MethodInvokationTest < Test::Unit::TestCase
  include RubyProf::Test

  class Test
    def do_something; end
    
    def test
      do_something
    end
    
    do_something_method = instance_method(:do_something)
    
    define_method :test_with_method_object do
      do_something_method.bind(self).call
    end
  end
  
  def setup
    @obj = Test.new
  end

  def test_method_invocation
    @obj.test
    @obj.test_with_method_object
  end
end