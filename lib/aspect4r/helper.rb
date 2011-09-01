require 'erb'

module Aspect4r
  module Helper
    def self.find_available_method_name klass, method_name_prefix
      0.upto(10000) do |i|
        m = "#{method_name_prefix}#{i}_#{klass.hash.abs}"
        return m unless klass.private_instance_methods(false).detect {|method| method.to_s == m }
      end
    end
    
    def self.creating_method?
      @creating_method
    end
    
    def self.define_method klass_or_module, *args, &block
      @creating_method = true
      klass_or_module.send :define_method, *args, &block
    ensure
      @creating_method = false
    end

    # Store original method in aspect data and refer to it whenever recreating method
    def self.process_advice meta_data, klass_or_module, *methods, &block
      methods.flatten!

      options = meta_data.default_options.clone
      options.merge!(methods.pop) if methods.last.is_a? Hash
      options.merge!(meta_data.mandatory_options)

      # Convert symbols to strings to avoid inconsistencies
      methods.size.times do |i|
        methods[i] = methods[i].to_s if methods[i].is_a? Symbol
      end

      if block_given?
        with_method = find_available_method_name klass_or_module, meta_data.with_method_prefix
        klass_or_module.send :define_method, with_method, &block
        klass_or_module.send :private, with_method
      else
        with_method = methods.pop
      end
      
      a4r_data = klass_or_module.a4r_data
      advice   = Aspect4r::Model::Advice.new(meta_data.advice_type, 
                                             Aspect4r::Model::MethodMatcher.new(*methods), 
                                             with_method, 
                                             a4r_data.group, 
                                             options)
      a4r_data << advice

      methods.each do |method|
        next unless method.is_a? String
        
        wrapped_method = a4r_data.wrapped_methods[method]
        
        if not wrapped_method and klass_or_module.instance_methods.detect {|m| m.to_s == method }
          wrapped_method = klass_or_module.instance_method(method)
          a4r_data.wrapped_methods[method] = wrapped_method
        end

        create_method klass_or_module, method if wrapped_method
      end
    end
    
    # method - target method
    def self.create_method klass, method
      @creating_method = true
      
      advices = klass.a4r_data.advices_for_method method
      return if advices.empty?
      
      grouped_advices = []
      group           = nil
      inner_most      = true

      advices.each do |advice|
        if ((group and group != advice.group) or advice.around?) and not grouped_advices.empty?
          create_method_with_advices klass, method, grouped_advices, inner_most
          
          grouped_advices = []
          inner_most      = false
        end
        
        grouped_advices << advice
        group           = advice.group
      end
      
      # create wrap method for before/after advices which are not wrapped inside around advice.
      create_method_with_advices klass, method, grouped_advices, inner_most unless grouped_advices.empty?
    ensure
      @creating_method = nil
    end
    
    # method
    # before_advices
    # after_advices
    METHOD_TEMPLATE = ERB.new <<-CODE, nil, '<>'
<% if inner_most %>
      wrapped_method = a4r_data.wrapped_methods['<%= method %>']
<% else %>
      wrapped_method = instance_method(:<%= method %>)
<% end %>

      define_method :<%= method %> do |*args, &block|
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

<% if around_advice %>
        # around advice
<%   if around_advice.options[:method_name_arg] %>
		    result = <%= around_advice.with_method %> '<%= method %>', *args do |*args|
          wrapped_method.bind(self).call *args, &block
        end
<%   else %>
        result = <%= around_advice.with_method %> *args do |*args|
          wrapped_method.bind(self).call *args, &block
        end
<%   end %>
<% else %>
        # Invoke wrapped method
        result = wrapped_method.bind(self).call *args, &block
<% end %>

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
    
    def self.create_method_with_advices klass, method, advices, inner_most
      before_advices = advices.select {|advice| advice.before? or advice.before_filter? }
      after_advices  = advices.select {|advice| advice.after?  }
      around_advice  = advices.first if advices.first.around?
      
      code = METHOD_TEMPLATE.result(binding)
      # puts code
      klass.class_eval code, __FILE__
    end
  end
end