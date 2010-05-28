$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'aspect4r'

class A
  include Aspect4r
  
  def test value
    puts 'test'
    value
  end
  
  around_method :test do |proxy_method, value|
    puts 'before test'
    result = send proxy_method, value
    puts 'after test'
    result
  end
end

puts "Example 1:"
puts A.new.test(1)
# ==== Output ====
# Example 1:
# before test
# test
# after test
# 1

