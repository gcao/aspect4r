$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'aspect4r'

class A
  include Aspect4r
  
  # a4r_debug_mode
  
  def test value
    puts 'test'
    value
  end
  
  before_method :test do |value|
    puts 'before test'
  end
  
  after_method :test do |result, value|
    puts 'after test'
    result
  end
  
  around_method :test do |proxy_method, value|
    puts 'around test 1'
    result = send proxy_method, value
    puts 'around test 2'
    result
  end
end

puts "Example 1:"
puts A.new.test(1)
# ==== Output ====
# Example 1:
# before test
# around test 1
# test
# around test 2
# after test
# 1

