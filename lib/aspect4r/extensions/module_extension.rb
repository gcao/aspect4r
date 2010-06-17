class Module
  def method_added_with_a4r(method)
    method_added_without_a4r(method)
    
    return if method.to_s =~ /a4r/

    # save unbound method and create new method
    if @a4r_data and method_advices = @a4r_data[method] and not Aspect4r::Helper.creating_method?
      method_advices.wrapped_method = instance_method(method)
      Aspect4r::Helper.create_method self, method
    end
  end
  
  alias method_added_without_a4r method_added
  alias method_added             method_added_with_a4r

  def singleton_method_added_with_a4r(method)
    singleton_method_added_without_a4r(method)
    
    return if method.to_s =~ /a4r/

    # save unbound method and create new method
    eigen_class = Aspect4r::Helper.eigen_class(self)
    my_advices  = eigen_class.instance_variable_get(:@a4r_data)
    
    if my_advices and method_advices = my_advices[method] and not Aspect4r::Helper.creating_method?
      method_advices.wrapped_method = eigen_class.instance_method(method)
      Aspect4r::Helper.create_method eigen_class, method
    end
  end
  
  alias singleton_method_added_without_a4r singleton_method_added
  alias singleton_method_added             singleton_method_added_with_a4r
end
