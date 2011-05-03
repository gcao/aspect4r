$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'aspect4r'

class A
  include Aspect4r
  
  before :test do |value|
    puts 'before test'
  end
  
  before_filter :test do |value|
    puts 'check before test'
    value >= 0
  end
  
  def test value
    puts 'test'
  end
end

puts "Example 1:"
A.new.test 1
# ==== Output ====
# before test
# check before test
# test

puts "\nExample 2:"
A.new.test -1
# ==== Output ====
# before test
# check before test
