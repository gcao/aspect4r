require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class AfterTest < Test::Unit::TestCase
  include RubyProf::Test

  class Klass
    include Aspect4r
    
    after :test, :after_test
    
    def test_no_aspect
      result = nil
      
      after_test result
    end
    
    def test; end
    
    def after_test result; end
  end

  def test_after
    o = Klass.new
    o.test_no_aspect
    o.test
  end
end