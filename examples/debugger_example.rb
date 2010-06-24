$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'aspect4r'
require 'aspect4r/debugger'

class A
  include Aspect4r
  
  Aspect4r.debug self, :test
  
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
  
  before :test, :do_something
  
  after :test do |result, value|
    puts 'after test'
    result
  end
  
  def do_something value
    puts 'before test'
  end
end

puts "Example 1:"
puts A.new.test(1)
Aspect4r.debug_end A, :test

# ==== Output ====
# a4r A#test: * Enabled debug mode for A#test
# a4r A#test: * method 'test' is created
# a4r A#test: * advice 0 is created with options {} and a block whose arity is 2
# a4r A#test: * advice 1 is created with options {} and method 'do_something'
# a4r A#test: * advice 2 is created with options {} and a block whose arity is 2
# Example 1:
# a4r A#test: Execution begins with arguments: 1
# a4r A#test: Invoke advice 1 with arguments: 1
# before test
# a4r A#test: advice 1 returns nil
# a4r A#test: Invoke advice 0 with arguments: <???>, 1
# around test 1
# a4r A#test: Invoke wrapped method with arguments 1
# test
# a4r A#test: Wrapped method returns 1
# around test 2
# a4r A#test: advice 0 returns 1
# a4r A#test: Invoke advice 2 with arguments: 1, 1
# after test
# a4r A#test: advice 2 returns 1
# a4r A#test: Execution finishes with result: 1
# 1
# a4r A#test: * Disabled debug mode for A#test
