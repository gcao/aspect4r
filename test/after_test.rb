require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class AfterTest < Test::Unit::TestCase
  include RubyProf::Test

  class Test
    include Aspect4r
    
    def test_no_aspect
      result = nil
      
      after_test result
    end
    
    def test; end
    
    def after_test result; end
    
    after_method :test, :after_test
  end
  
  def setup
    @obj = Test.new
  end

  def test_after
    @obj.test_no_aspect
    @obj.test
  end
end