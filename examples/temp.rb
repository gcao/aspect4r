$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'aspect4r'

A = Class.new do
  include Aspect4r
  
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
  
  p a4r_definitions
end

p A.a4r_definitions # Should output 3 aspects

# puts "Example 1:"
# puts A.new.test(1)
# ==== Output ====
# Example 1:
# before test
# around test 1
# test
# around test 2
# after test
# 1

