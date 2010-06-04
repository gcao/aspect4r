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
    
    def self.creating_method?
      @creating_method
    end
    
    # Store original method in aspect data and refer to it whenever recreating method
    def self.process_advice meta_data, klass_or_module, *methods, &block
      methods.flatten!
      
      options = meta_data.default_options.clone
      options.merge!(methods.pop) if methods.last.is_a? Hash
      options.merge!(meta_data.mandatory_options)
      
      if block_given?
        with_method = find_available_method_name klass_or_module, meta_data.with_method_prefix
        klass_or_module.send :define_method, with_method, &block
      else
        with_method = methods.pop
      end
      
      methods.each do |method|
        method = method.to_sym
        klass_or_module.a4r_data.methods_with_advices << method
        
        aspect = klass_or_module.a4r_data[method] ||= Aspect4r::Model::AdvicesForMethod.new(method)
        aspect.add Aspect4r::Model::Advice.new(meta_data.advice_type, with_method, to_group(klass_or_module), options)
        
        if not aspect.wrapped_method and klass_or_module.instance_methods.include?(method.to_s)
          aspect.wrapped_method = klass_or_module.instance_method(method)
        end
        
        create_method klass_or_module, method if aspect.wrapped_method
      end
    end
    
    # method
    # advice
    WRAP_METHOD_TEMPLATE = ERB.new <<-CODE, nil, '<>'
<% if inner_most %>
      wrapped_method = a4r_data[:<%= method %>].wrapped_method
<% else %>
      wrapped_method = instance_method(:<%= method %>)
<% end %>

      define_method :<%= method %> do |*args|
<% if advice.options[:method_name_arg] %>
        result = <%= advice.with_method %> '<%= method %>', wrapped_method, *args
<% else %>
        result = <%= advice.with_method %> wrapped_method, *args
<% end %>
        
        result
      end
    CODE
    
    def self.create_method_for_around_advice klass, method, advice, inner_most
      code = WRAP_METHOD_TEMPLATE.result(binding)
      # puts code
      klass.class_eval code, __FILE__
    end
    
    # method
    # before_advices
    # after_advices
    METHOD_TEMPLATE = ERB.new <<-CODE, nil, '<>'
<% if inner_most %>
      wrapped_method = a4r_data[:<%= method %>].wrapped_method
<% else %>
      wrapped_method = instance_method(:<%= method %>)
<% end %>

      define_method :<%= method %> do |*args|
        result = nil

        # Before advices
<% before_advices.each do |definition| %>
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

        # Call wrapped method
        result = wrapped_method.bind(self).call *args

        # After advices
<% after_advices.each do |definition| %>
<% if definition.options[:method_name_arg] and definition.options[:result_arg] %>
        result = <%= definition.with_method %> '<%= method %>', result, *args
<% elsif definition.options[:method_name_arg] %>
        <%= definition.with_method %> '<%= method %>', *args
<% elsif definition.options[:result_arg] %>
        result = <%= definition.with_method %> result, *args
<% else %>
        <%= definition.with_method %> *args
<% end %>
<% end %>
        
        result
      end
    CODE
    
    def self.create_method_for_before_after_advices klass, method, advices, inner_most
      before_advices = advices.select {|advice| advice.before? }
      after_advices  = advices.select {|advice| advice.after?  }
      
      code = METHOD_TEMPLATE.result(binding)
      # puts code
      klass.class_eval code, __FILE__
    end
    
    # method - target method
    # aspect - instance of AdvicesForMethod which contains aspect definitions for target method
    def self.create_method klass, method
      @creating_method = true
      
      aspect = klass.a4r_data[method.to_sym]

      if aspect.nil? or aspect.empty?
        # There is no aspect defined.
        @creating_method = nil
        return
      end
      
      grouped_advices = []
      inner_most = true

      aspect.advices.each do |advice|
        if advice.around? and not grouped_advices.empty?
          # wrap up advices before current advice
          create_method_for_before_after_advices klass, method, grouped_advices, inner_most
          
          inner_most = false
          
          grouped_advices = []
        end
        
        # handle current advice
        if advice.around?
          create_method_for_around_advice klass, method, advice, inner_most
          inner_most = false
        else
          grouped_advices << advice
        end
      end
      
      # create wrap method for before/after advices which are not wrapped inside around advice.
      unless grouped_advices.empty?
        create_method_for_before_after_advices klass, method, grouped_advices, inner_most unless grouped_advices.empty?
      end

      @creating_method = nil
    end
  end
end