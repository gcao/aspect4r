require 'erb'

module Aspect4r
  module Helper
    def self.find_available_method_name klass, method_name_prefix
      0.upto(10000) do |i|
        m = "#{method_name_prefix}#{i}_#{klass.hash}"
        return m unless klass.instance_methods.include?(m)
      end
    end
    
    def self.to_group class_or_module
      class_or_module.hash
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
    
    # Use local variables: wrap_method, wrapped_method(method to be invoked from inside), method, definition(around aspect definition)
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
    
    def self.create_method_for_around_advice klass, method, wrapped_method, advice
      code = WRAP_METHOD_TEMPLATE.result(binding)
      klass.class_eval code
    end
    
    # Use local variables: method, wrap_method(backup of original method or wrap method of outmost around aspect) and aspect 
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
      
      grouped_advices = []
      
      aspect.advices.each do |advice|
        if advice.around?
          wrap_method = create_method_for_before_after_advices klass, method, wrap_method, advices unless grouped_advices.empty?

          wrap_method = create_method_for_around_advice klass, method, wrap_method, advice
          
          grouped_advices = []
        else
          grouped_advices << advice
        end
      end
      
      unless grouped_advices.empty?
        wrap_method = create_method_for_before_after_advices klass, method, wrap_method, advices unless grouped_advices.empty?
        alias method wrap_method
        remove_method wrap_method
      end
      
      if aspect.around_aspects?
        aspect.around_aspects.reverse.each_with_index do |definition, i|
          wrap_method    = wrap_method(method, i)
          wrapped_method = wrapped_method(method, i)

          code = WRAP_METHOD_TEMPLATE.result(binding)
          klass.class_eval code
        end
        
        unless aspect.before_aspects? or aspect.after_aspects?
          klass.send :alias_method, method, wrap_method
          klass.send :remove_method, wrap_method
          return
        end
      end
      
      code = METHOD_TEMPLATE.result(binding)
      # puts code
      klass.class_eval code
    end
  end
end