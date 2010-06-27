require 'erb'

module Aspect4r
  module Helper
    def self.find_available_method_name klass, method_name_prefix
      0.upto(10000) do |i|
        m = "#{method_name_prefix}#{i}_#{klass.hash}"
        return m unless klass.private_instance_methods(false).include?(m)
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
      
      options_arg = methods.last.is_a?(Hash) ? methods.pop : {}
      
      options.merge!(options_arg)
      options.merge!(meta_data.mandatory_options)
      
      if block_given?
        with_method = find_available_method_name klass_or_module, meta_data.with_method_prefix
        klass_or_module.send :define_method, with_method, &block
        klass_or_module.send :private, with_method
      else
        with_method = methods.pop
      end
      
      a4r_data = klass_or_module.a4r_data
      advice   = Aspect4r::Model::Advice.new(meta_data.advice_type, with_method, a4r_data.group, options)
      
      methods.each do |method|
        method = method.to_sym
        
        aspect = a4r_data[method] ||= Aspect4r::Model::AdvicesForMethod.new(method)
        aspect.add advice
        
        if debugger = Aspect4r.debugger(klass_or_module, method)
          index = aspect.index(advice)
          block_or_method_message = 
            if block_given?
              "a block whose arity is #{block.arity}"  
            else
              "method \"#{with_method}\""
            end
          
          debugger.add_meta("advice#{index} <#{advice.advice_type_name.upcase}> is created with options #{options_arg.inspect} and #{block_or_method_message}")
        end
        
        if not aspect.wrapped_method and klass_or_module.instance_methods.include?(method.to_s)
          wrapped_method = aspect.wrapped_method = klass_or_module.instance_method(method)
          wrapped_method.instance_variable_set "@advised_method", true
        end
        
        create_method klass_or_module, method if aspect.wrapped_method
      end
    end
    
    # method - target method
    def self.create_method klass, method
      @creating_method = true
      
      aspect = klass.a4r_data[method.to_sym]
      
      return if aspect.nil? or aspect.empty?
      
      grouped_advices = []
      group           = nil
      inner_most      = true

      aspect.each do |advice|
        if ((group and group != advice.group) or advice.around?) and not grouped_advices.empty?
          create_method_with_advices klass, method, grouped_advices, inner_most
          
          grouped_advices = []
          inner_most      = false
        end
        
        grouped_advices << advice
        group           = advice.group
      end
      
      # Handle advices not processed.
      create_method_with_advices klass, method, grouped_advices, inner_most unless grouped_advices.empty?
    ensure
      @creating_method = nil
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
        <% if outer_most %>debugger.add("Execution begins with arguments: \#{args}") <% end %>

        result = nil

<% before_advices.each do |advice| %>
        # before advice
<%   advice_name = "advice\#{klass.a4r_data[method].index(advice)}" if debugger %>
<%   if advice.options[:method_name_arg] %>
        <% if debugger %>debugger.add("<%= advice_name %> is invoked with arguments: \"<%= method %>\", \#{args}") <% end %>
        result = <%= advice.with_method %> '<%= method %>', *args
<%   else %>
        <% if debugger %>debugger.add("<%= advice_name %> is invoked with arguments: \#{args}") <% end %>
        result = <%= advice.with_method %> *args
<%   end %>
        <% if debugger %>debugger.add("<%= advice_name %> returns \#{result.inspect}") <% end %>
        return result.value if result.is_a? ReturnThis
<%   if advice.options[:skip_if_false] %>
        return unless result
<%   end %>
<% end %>

<% if around_advice %>
<%   advice_name = "advice\#{klass.a4r_data[method].index(around_advice)}" if debugger %>
        # around advice
<%   if around_advice.options[:method_name_arg] %>
        <% if debugger %>debugger.add("<%= advice_name %> is invoked with arguments: \"<%= method %>\", \#{wrapped_method}, \#{args}") <% end %>
        result = <%= around_advice.with_method %> '<%= method %>', wrapped_method, *args
<%   else %>
        <% if debugger %>debugger.add("<%= advice_name %> is invoked with arguments: \#{wrapped_method}, \#{args}") <% end %>
        result = <%= around_advice.with_method %> wrapped_method, *args
<%   end %>
        <% if debugger %>debugger.add("<%= advice_name %> returns \#{result.inspect}") <% end %>
<% else %>
        # Invoke wrapped method
        <% if debugger %>debugger.add("\"\#{method}\" is invoked with arguments: \#{args}") <% end %>
        result = wrapped_method.bind(self).call *args
        <% if debugger %>debugger.add("\"\#{method}\" returns \#{result.inspect}") <% end %>
<% end %>

<% after_advices.each do |advice| %>
        # after advice
<%   advice_name = "advice\#{klass.a4r_data[method].index(advice)}" if debugger %>
<%   if advice.options[:method_name_arg] and advice.options[:result_arg] %>
        <% if debugger %>debugger.add("<%= advice_name %> is invoked with arguments: \"<%= method %>\", \#{result}, \#{args}") <% end %>
        result = <%= advice.with_method %> '<%= method %>', result, *args
<%   elsif advice.options[:method_name_arg] %>
        <% if debugger %>debugger.add("<%= advice_name %> is invoked with arguments: \"<%= method %>\", \#{args}") <% end %>
        <%= advice.with_method %> '<%= method %>', *args
<%   elsif advice.options[:result_arg] %>
        <% if debugger %>debugger.add("<%= advice_name %> is invoked with arguments: \#{result}, \#{args}") <% end %>
        result = <%= advice.with_method %> result, *args
<%   else %>
        <%= advice.with_method %> *args
<%   end %>
        <% if debugger %>debugger.add("<%= advice_name %> returns \#{result.inspect}") <% end %>
<% end %>
        
        <% if outer_most %>debugger.add("Execution finishes with result: \#{result.inspect}") <% end %>
        result
      end
    CODE
    
    def self.create_method_with_advices klass, method, advices, inner_most
      if debugger = Aspect4r.debugger(klass, method)
        outer_most = klass.a4r_data[method].last == advices.last
      end
      
      before_advices = advices.select {|advice| advice.before? or advice.before_filter? }
      after_advices  = advices.select {|advice| advice.after?  }
      around_advice  = advices.first if advices.first.around?
      
      code = METHOD_TEMPLATE.result(binding)
      # puts code
      klass.class_eval code, __FILE__
    end
  end
end