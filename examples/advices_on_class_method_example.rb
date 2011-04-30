$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'aspect4r'

class A
  class << self
    include Aspect4r
    
    around :test do |input, &block|
      puts 'around test (before)'
      result = block.call input
      puts 'around test (after)'
      result
    end
    
    before :test do |input|
      puts 'before test'
    end
    
    after :test do |result, input|
      puts 'after test'
      result
    end
    
    def test input
      puts 'test'
      input
    end
  end
end

puts "Example 1:"
puts A.test(1)
# ==== Output ====
# before test
# around test (before)
# test
# around test (after)
# after test
# 1
