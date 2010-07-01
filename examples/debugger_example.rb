$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'aspect4r'
require 'aspect4r/debugger'

class A
  include Aspect4r

  Aspect4r.debug A, :test
  
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
Aspect4r.debug_end

# ==== Output ====
# a4r A#test: * Enabled debug mode for A#test
# a4r A#test: * method "test" is created
# a4r A#test: * advice0 <AROUND> is created with options {} and a block whose arity is 2
# a4r A#test: * advice1 <BEFORE> is created with options {} and method "do_something"
# a4r A#test: * advice2 <AFTER> is created with options {} and a block whose arity is 2
# Example 1:
# a4r A#test: Execution begins with arguments: 1
# a4r A#test: advice1 is invoked with arguments: 1
# before test
# a4r A#test: advice1 returns nil
# a4r A#test: advice0 is invoked with arguments: #<UnboundMethod: A#test>, 1
# around test 1
# a4r A#test: "test" is invoked with arguments: 1
# test
# a4r A#test: "test" returns 1
# around test 2
# a4r A#test: advice0 returns 1
# a4r A#test: advice2 is invoked with arguments: 1, 1
# after test
# a4r A#test: advice2 returns 1
# a4r A#test: Execution finishes with result: 1
# 1
# a4r A#test: * Disabled debug mode for A#test
