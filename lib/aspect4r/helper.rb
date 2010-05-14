module Aspect4r
  module Helper
    def self.find_available_method_name klass, method_name_prefix
      0.upto(10000) do |i|
        m = "#{method_name_prefix}#{i}"
        return m unless klass.instance_methods.include?(m)
      end
    end
    
    def self.backup_method_name method
      "#{method}_without_a4r"
    end
    
    def self.wrap_method method, i
      "#{method}_a4r_around_#{i}"
    end
    
    def self.wrapped_method method, i
      if i > 0
        "#{method}_a4r_around_#{i - 1}"
      else
        backup_method_name(method)
      end
    end
      
    def self.backup_original_method klass, method
      method             = method.to_s
      method_without_a4r = backup_method_name(method)

      if klass.instance_methods.include?(method) and not klass.instance_methods.include?(method_without_a4r)
        klass.send :alias_method, method_without_a4r, method
      end
    end
    
    # method      - target method
    # definitions - instance of AspectForMethod which contains aspect definitions for target method
    def self.create_method klass, method, aspect
      if aspect.empty?
        # There is no aspect defined.
        klass.send :alias_method, method, backup_method_name(method)
        return
      end
      
      if aspect.around_aspects?
        aspect.around_aspects.reverse.each_with_index do |definition, i|
          wrap_method    = wrap_method(method, i)
          wrapped_method = wrapped_method(method, i)
          
          klass.send :define_method, wrap_method do |*args|
            self.class.a4r_debug method, "Aspect: #{definition.inspect}" if self.class.a4r_debug_mode?
            
            result = send definition.with_method, wrapped_method, *args
            
            self.class.a4r_debug method, "Result: #{result.inspect}" if self.class.a4r_debug_mode?
            
            result
          end
        end
      end
      
      klass.send :define_method, method do |*args|
        self.class.a4r_debug method, "Entering #{method}(#{args.inspect[1..-2]})" if self.class.a4r_debug_mode?
        
        self.class.a4r_debug method, "'before' aspects: #{aspect.before_aspects.length}" if self.class.a4r_debug_mode?
        
        result = nil
        
        aspect.before_aspects.each do |definition|
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
        
        if aspect.around_aspects.empty?
          self.class.a4r_debug method, "Invoking original method" if self.class.a4r_debug_mode?
          
          result = send(:"#{method}_without_a4r", *args)
        else
          self.class.a4r_debug method, "'around' aspects: #{aspect.around_aspects.length}" if self.class.a4r_debug_mode?
          
          wrap_method = Aspect4r::Helper.wrap_method(method, aspect.around_aspects.length - 1)
          result = send wrap_method, *args
        end
        
        self.class.a4r_debug method, "Result: #{result.inspect}" if self.class.a4r_debug_mode?

        self.class.a4r_debug method, "'after' aspects: #{aspect.after_aspects.length}" if self.class.a4r_debug_mode?
        
        aspect.after_aspects.each do |definition|
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