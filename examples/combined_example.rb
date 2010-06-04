$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'aspect4r'

class A
  include Aspect4r
  
  def test value
    puts 'test'
    value
  end
  
  around :test do |proxy, value|
    puts 'around test 1'
    result = a4r_invoke proxy, value
    puts 'around test 2'
    result
  end
  
  before :test do |value|
    puts 'before test'
  end
  
  after :test do |result, value|
    puts 'after test'
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
