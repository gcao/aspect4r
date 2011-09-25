$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'aspect4r'

class A
  include Aspect4r
  
  around :test do |*args, &block|
    puts 'around test 1'
    result = block.call *args
    puts 'around test 2'
    result
  end
  
  before :test do |*args|
    puts 'before test'
  end
  
  after :test do |result, *args|
    puts 'after test'
    result
  end
  
  def test *args
    puts 'test'
    if block_given?
      yield *args
    else
      args[0]
    end
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
puts "\n\nExample 2:"
puts A.new.test(1){ puts 'in block'; 2 }
# ==== Output ====
# Example 2:
# before test
# around test 1
# test
# in block
# around test 2
# after test
# 2
puts "\n\nExample 3:"
puts A.new.test(1){ |*args| puts 'in block'; args[0] + 2 }
# ==== Output ====
# Example 3:
# before test
# around test 1
# test
# in block
# around test 2
# after test
# 3
