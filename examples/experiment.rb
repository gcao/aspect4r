# New approach:
#   Require methods to exist when the advise block is executed, meaning that
#     advices can not be applied to methods defined dynamically (this is still possible)
#   Does not modify method_added, :singleton_method_added etc

class A; end
class B; end

# Options to on() are merged with options for individual advices, and advice specific 
# option has higher priority.
Aspect4r.on(A, B, :private_methods => true) do
  before :test    { puts 'before test' }
  before :do_this { puts 'before do_this' }

  # Methods defined inside block will not be a part of A. We have to use
  # lambda here if advice logic is used by several advices. That advice logic
  # will be used to create new methods for all those advices though.
  advice1 = lambda {|method| puts "before #{method}" }

  before /^do_.*/, advice1, :future_methods => true, :method_name_arg => true
end

# We could add aspect4r method to Module to simplify above code to this

class A
  aspect4r :private_methods => true do
    before :test { puts 'before test' }
  end
end


# Current approach

class C
  include Aspect4r

  before :test    { puts 'before test' }
  before :do_this { puts 'before do_this' }

end

