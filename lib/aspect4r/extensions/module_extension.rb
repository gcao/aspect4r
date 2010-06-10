class Module
  def included_with_a4r(base)
    included_without_a4r(base) if respond_to?(:included_without_a4r)
    
    return if @a4r_data.nil? or @a4r_data.empty?
  
    base.send(:include, Aspect4r)
    
    existing_aspects = base.a4r_data
    existing_aspects.methods_with_advices.merge(@a4r_data.methods_with_advices)    
  end
  
  alias included_without_a4r included
  alias included             included_with_a4r
  
  def method_added_with_a4r(method)
    method_added_without_a4r(method) if respond_to?(:method_added_without_a4r)
    
    return if method.to_s =~ /a4r/

    # save unbound method and create new method
    if not Aspect4r::Helper.creating_method? and @a4r_data and method_advices = @a4r_data[method]
      method_advices.wrapped_method = instance_method(method)
      Aspect4r::Helper.create_method self, method
    end
  end
  
  alias method_added_without_a4r method_added
  alias method_added             method_added_with_a4r

  def singleton_method_added_with_a4r(method)
    # puts "singleton_method_added_with_a4r(#{method})"
    singleton_method_added_without_a4r(method) if respond_to?(:singleton_method_added_without_a4r)
    
    return if method.to_s =~ /a4r/

    # save unbound method and create new method
    if not Aspect4r::Helper.creating_method? and @a4r_data and method_advices = @a4r_data[method]
      method_advices.wrapped_method = instance_method(method)
      Aspect4r::Helper.create_method self, method
    end
  end
  
  alias singleton_method_added_without_a4r singleton_method_added
  alias singleton_method_added             singleton_method_added_with_a4r
end
