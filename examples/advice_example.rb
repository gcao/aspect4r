module Advices
  include Aspect4r
  
  before_advice :before_xxx do |*args|
    puts 'before_xxx'
  end
  
  after_advice  :after_xxx  do |result, *args|
    puts 'after_xxx'
    result
  end
  
  around_advice :around_xxx do |proxy, *args|
    puts 'around_xxx 1'
    result = send proxy, *args
    puts 'around_xxx 2'
    result
  end
  
  advice_group :combined, :around_xxx, :before_xxx, :after_xxx
  
  # Another example
  # advice_group :combined do
  #   before_advice do |*args|
  #   end
  #
  #   after_advice do |result, *args|
  #   end
  # end
end

class C
  include Advices
  
  apply_advice :combined, :test
  
  def test value
    puts 'test'
    value
  end
end

puts "Example 1:"
puts C.new.test(1)
# ==== Output ====
# Example 1:
# before_xxx
# around_xxx 1
# test
# around_xxx 2
# after_xxx
# 1
