$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'aspect4r'

class A
  include Aspect4r
  
  def test value
    puts 'test'
    value
  end
  
  around :test do |proxy, value|
    puts 'before test'
    result = send proxy, value
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

