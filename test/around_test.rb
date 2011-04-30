require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class AroundTest < Test::Unit::TestCase
  include RubyProf::Test

  class Test
    include Aspect4r
    
    around :test, :around_test
    
    def test_no_aspect; end
    
    def test; end
    
    def around_test
      yield
    end
  end
  
  def setup
    @obj = Test.new
  end

  def test_around
    @obj.test_no_aspect
    @obj.test
  end
end