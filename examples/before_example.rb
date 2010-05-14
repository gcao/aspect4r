$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'aspect4r/before'

class A
  include Aspect4r::Before
  
  # a4r_debug_mode
  
  def test value
    puts 'test'
  end
  
  before_method :test do |value|
    puts 'before test'
  end
  
  before_method_check :test do |value|
    puts 'check before test'
    value >= 0
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

module M
  include Aspect4r::Before
  
  before_method :test do |value|
    puts 'before test'
  end
  
  before_method_check :test do |value|
    puts 'check before test'
    value >= 0
  end
end

class B
  def test value
    puts 'test'
  end
  
  include M
end

puts "\nExample 3:"
B.new.test 1
# ==== Output ====
# before test
# check before test
# test

  
