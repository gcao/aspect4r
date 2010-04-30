module Aspect4r
  module Helper
    def self.find_available_method_name klass, method_name_prefix
      0.upto(10000) do |i|
        m = "#{method_name_prefix}#{i}"
        unless klass.instance_methods.include?(m.to_s)
          return m.to_sym
        end
      end
    end
  end
end