require 'erb'

module Aspect4r
  module Helper
    def self.find_available_method_name klass, method_name_prefix
      0.upto(10000) do |i|
        m = "#{method_name_prefix}#{i}_#{klass.hash}"
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
    
    def self.create_method_placeholder klass, method
      klass.class_eval <<-CODE
        def #{method} *args
          aspect = self.class.a4r_definitions[:'#{method}']
          Aspect4r::Helper.create_method self.class, :'#{method}', aspect
          #{method} *args
        end
      CODE
    end
    
    WRAP_METHOD_TEMPLATE = ERB.new <<-CODE
      def <%= wrap_method %> *args
        <% if definition.options[:method_name_arg] %>
        result = <%= definition.with_method %> '<%= method %>', '<%= wrapped_method %>', *args
        <% else %>
        result = <%= definition.with_method %> '<%= wrapped_method %>', *args
        <% end %>
        
        result
      end
    CODE
    
    # Use local variables: method, wrap_method and aspect 
    METHOD_TEMPLATE = ERB.new <<-CODE
      def <%= method %> *args
        result = nil
        <% aspect.before_aspects.each do |definition| %>
          <% if definition.options[:method_name_arg] %>
        result = <%= definition.with_method %> '<%= method %>', *args
          <% else %>
        result = <%= definition.with_method %> *args
          <% end %>
          
        return result.value if result.is_a? ReturnThis
          
          <% if definition.options[:skip_if_false] %>
        return unless result
          <% end %>
        <% end %>
        
        result = <%= wrap_method %> *args
        
        <% aspect.after_aspects.each do |definition| %>
          <% if definition.options[:method_name_arg] %>
        result = <%= definition.with_method %> '<%= method %>', result, *args
          <% else %>
        result = <%= definition.with_method %> result, *args
          <% end %>
        <% end %>
        
        result
      end
    CODE
    
    # method - target method
    # aspect - instance of AspectForMethod which contains aspect definitions for target method
    def self.create_method klass, method, aspect
      if aspect.nil? or aspect.empty?
        # There is no aspect defined.
        klass.send :alias_method, method, backup_method_name(method)
        return
      end
      
      wrap_method = backup_method_name(method)
      
      if aspect.around_aspects?
        aspect.around_aspects.reverse.each_with_index do |definition, i|
          wrap_method    = wrap_method(method, i)
          wrapped_method = wrapped_method(method, i)

          code = WRAP_METHOD_TEMPLATE.result(binding)
          puts code
          klass.class_eval code
          
          # klass.send :define_method, wrap_method do |*args|
          #   self.class.a4r_debug method, "Aspect: #{definition.inspect}" if self.class.a4r_debug_mode?
          #   
          #   if definition.options[:method_name_arg]
          #     result = send definition.with_method, method.to_s, wrapped_method, *args
          #   else
          #     result = send definition.with_method, wrapped_method, *args
          #   end
          #   
          #   self.class.a4r_debug method, "Result: #{result.inspect}" if self.class.a4r_debug_mode?
          #   
          #   result
          # end
        end
        
        unless aspect.before_aspects? or aspect.after_aspects?
          klass.send :alias_method, method, wrap_method
          klass.send :remove_method, wrap_method
          return
        end
      end
      
      code = METHOD_TEMPLATE.result(binding)
      puts code
      klass.class_eval code
      
      # klass.send :define_method, method do |*args|
      #   self.class.a4r_debug method, "Entering #{method}(#{args.inspect[1..-2]})" if self.class.a4r_debug_mode?
      #   
      #   self.class.a4r_debug method, "'before' aspects: #{aspect.before_aspects.length}" if self.class.a4r_debug_mode?
      #   
      #   result = nil
      #   
      #   aspect.before_aspects.each do |definition|
      #     self.class.a4r_debug method, "Aspect: #{definition.inspect}" if self.class.a4r_debug_mode?
      #     
      #     if definition.options[:method_name_arg]
      #       result = send(definition.with_method, method.to_s, *args)
      #     else
      #       result = send(definition.with_method, *args)
      #     end
      #     
      #     self.class.a4r_debug method, "Result: #{result.inspect}" if self.class.a4r_debug_mode?
      #     
      #     break if result.is_a? ReturnThis
      #     
      #     if definition.options[:skip_if_false] and not result
      #       self.class.a4r_debug method, "Wrap up result with ReturnThis" if self.class.a4r_debug_mode?
      # 
      #       result = ReturnThis.new(result)
      #       break
      #     end
      #   end
      #   
      #   if result.is_a? ReturnThis
      #     self.class.a4r_debug method, "Leaving #{method} with result: #{result.value.inspect}" if self.class.a4r_debug_mode?
      #     return result.value
      #   end
      #   
      #   result = send(wrap_method, *args)
      #   
      #   self.class.a4r_debug method, "Result: #{result.inspect}" if self.class.a4r_debug_mode?
      # 
      #   self.class.a4r_debug method, "'after' aspects: #{aspect.after_aspects.length}" if self.class.a4r_debug_mode?
      #   
      #   aspect.after_aspects.each do |definition|
      #     self.class.a4r_debug method, "Aspect: #{definition.inspect}" if self.class.a4r_debug_mode?
      #     
      #     if definition.options[:method_name_arg]
      #       result = send(definition.with_method, method.to_s, result, *args)
      #     else
      #       result = send(definition.with_method, result, *args)
      #     end
      #     
      #     self.class.a4r_debug method, "Result: #{result.inspect}" if self.class.a4r_debug_mode?
      #   end
      #   
      #   self.class.a4r_debug method, "Leaving #{method} with result: #{result.inspect}" if self.class.a4r_debug_mode?
      #   
      #   result
      # end
    end
  end
end