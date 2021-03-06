$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'aspect4r'

class A
  include Aspect4r
  
  around :test do |value, &block|
    puts 'before test'
    result = block.call value
    puts 'after test'
    result
  end
  
  def test value
    puts 'test'
    value
  end
end

puts A.new.test(1)
# ==== Output ====
# before test
# test
# after test
# 1

