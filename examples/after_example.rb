$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'aspect4r'

class A
  include Aspect4r
  
  def test value
    puts 'test'
    value
  end
  
  after :test do |result, value|
    puts 'after test'
    result
  end
  
  after :test do |result, value|
    puts 'after test 2'
    result * 100
  end
end

puts "Example 1:"
puts A.new.test(1)
# ==== Output ====
# test
# after test
# after test 2
# 100

