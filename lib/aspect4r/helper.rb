module Aspect4r
  module Helper
    def self.find_available_method_name klass, method_name_prefix
      0.upto(10000) do |i|
        m = "#{method_name_prefix}#{i}"
        return m unless klass.instance_methods.include?(m)
      end
    end
      
    def self.backup_original_method klass, method
      method             = method.to_s
      method_without_a4r = "#{method}_without_a4r"

      if klass.instance_methods.include?(method) and not klass.instance_methods.include?(method_without_a4r)
        klass.send :alias_method, method_without_a4r, method
      end
    end
    
    # method      - target method
    # definitions - an array of Aspect4r::Definition
    def self.create_method klass, method, definitions
      klass.send :define_method, method do |*args|
        self.class.a4r_debug method, "Entering #{method}(#{args.inspect[1..-2]})" if self.class.a4r_debug_mode?
        self.class.a4r_debug method, "Aspects: #{definitions.length}" if self.class.a4r_debug_mode?
        
        before_defs = definitions.select {|definition| definition.before? }
        
        self.class.a4r_debug method, "'before' aspects: #{before_defs.length}" if self.class.a4r_debug_mode?
        
        result = nil
        
        before_defs.each do |definition|
          self.class.a4r_debug method, "Aspect: #{definition.inspect}" if self.class.a4r_debug_mode?
          
          result = send(definition.with_method, *args)
          
          self.class.a4r_debug method, "Result: #{result.inspect}" if self.class.a4r_debug_mode?
          
          break if result.is_a? ReturnThis
          
          if definition.options[:skip_if_false] and not result
            self.class.a4r_debug method, "Wrap up result with ReturnThis" if self.class.a4r_debug_mode?

            result = ReturnThis.new(result)
            break
          end
        end
        
        if result.is_a? ReturnThis
          self.class.a4r_debug method, "Leaving #{method} with result: #{result.value.inspect}" if self.class.a4r_debug_mode?
          return result.value
        end
        
        self.class.a4r_debug method, "Invoking original method" if self.class.a4r_debug_mode?
          
        result = send(:"#{method}_without_a4r", *args)
        
        self.class.a4r_debug method, "Result: #{result.inspect}" if self.class.a4r_debug_mode?

        after_defs = definitions.select {|definition| definition.after? }
        
        self.class.a4r_debug method, "'after' aspects: #{after_defs.length}" if self.class.a4r_debug_mode?
        
        after_defs.each do |definition|
          self.class.a4r_debug method, "Aspect: #{definition.inspect}" if self.class.a4r_debug_mode?
          
          result = send(definition.with_method, *([result] + args))
          
          self.class.a4r_debug method, "Result: #{result.inspect}" if self.class.a4r_debug_mode?
        end
        
        self.class.a4r_debug method, "Leaving #{method} with result: #{result.inspect}" if self.class.a4r_debug_mode?
        
        result
      end
    end
  end
end