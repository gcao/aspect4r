require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class CombinedTest < Test::Unit::TestCase
  include RubyProf::Test

  class Test
    include Aspect4r
    
    before :test, :before_test
    after  :test, :after_test
    around :test, :around_test
    
    def test_no_aspect
      before_test
      
      result = nil
      
      after_test result
    end
    
    def test; end
    
    def before_test; end
    
    def after_test result; end
    
    def around_test
      yield
    end
  end
  
  def setup
    @obj = Test.new
  end

  def test_combined
    @obj.test_no_aspect
    @obj.test
  end
end