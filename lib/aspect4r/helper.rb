module Aspect4r
  module Helper
    def self.find_available_method_name klass, method_name_prefix
      0.upto(10000) do |i|
        m = "#{method_name_prefix}#{i}"
        return m unless klass.instance_methods.include?(m)
      end
    end
  end
end