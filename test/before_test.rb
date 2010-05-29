require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class BeforeTest < Test::Unit::TestCase
  include RubyProf::Test

  class Test
    include Aspect4r
    
    before :test, :before_test
    
    def test_no_aspect
      before_test
    end
    
    def test; end
    
    def before_test; end
  end
  
  def setup
    @obj = Test.new
  end

  def test_before
    @obj.test_no_aspect
    @obj.test
  end
end