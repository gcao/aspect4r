require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class AroundTest < Test::Unit::TestCase
  include RubyProf::Test

  class Test
    include Aspect4r
    
    def test_no_aspect; end
    
    def test; end
    
    def around_test proxy_method
      send proxy_method
    end
    
    around_method :test, :around_test
  end
  
  def setup
    @obj = Test.new
  end

  def test_around
    @obj.test_no_aspect
    @obj.test
  end
end