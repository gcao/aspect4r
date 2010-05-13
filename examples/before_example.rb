$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'aspect4r'

class A
  include Aspect4r
  
  a4r_debug_mode
  
  def test value
    puts 'test'
  end
  
  before_method :test do |value|
    puts 'before test'
  end
  
  before_method_check :test do |value|
    value >= 0
  end
end

puts "Example 1:"
A.new.test 1
# ==== Output ====
# before test
# test

puts "\nExample 2:"
A.new.test -1
# ==== Output ====
# before test
