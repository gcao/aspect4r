require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class BeforeTest < Test::Unit::TestCase
  include RubyProf::Test

  class Test
    include Aspect4r
    
    def test_no_aspect
      before_test
    end
    
    def test; end
    
    def before_test; end
    
    before_method :test, :before_test
  end
  
  def setup
    @obj = Test.new
  end

  def test_before
    @obj.test_no_aspect
    @obj.test
  end
end