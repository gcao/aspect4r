require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class CombinedTest < Test::Unit::TestCase
  include RubyProf::Test

  class Test
    include Aspect4r
    
    def test_no_aspect
      before_test
      
      result = nil
      
      after_test result
    end
    
    def test; end
    
    def before_test; end
    
    def after_test result; end
    
    def around_test proxy_method
      send proxy_method
    end
    
    before_method :test, :before_test
    after_method  :test, :after_test
    around_method :test, :around_test
  end
  
  def setup
    @obj = Test.new
  end

  def test_combined
    @obj.test_no_aspect
    @obj.test
  end
end