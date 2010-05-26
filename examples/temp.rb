$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'aspect4r'

class A
  include Aspect4r
  
  def test
    puts 'A: test'
  end
  
  before_method :test do
    puts 'A: before(test)'
  end
end

class B < A
  include Aspect4r
  
  before_method :test do
    puts 'B: before(test)'
  end
end

B.new.test
