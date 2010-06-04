class Module
  # TODO: copy over list of methods which have advices
  def included_with_a4r(base)
    included_without_a4r(child) if respond_to?(:included_without_a4r)
    
    return if @a4r_data.nil? or @a4r_data.empty?
  
    base.send(:include, Aspect4r)
    
    existing_aspects = base.a4r_data
    existing_aspects.methods_with_advices.merge(@a4r_data.methods_with_advices)
    
    # # For each method in a4r_data of INCLUDED module
    # #   Backup xxx as xxx_without_a4r for each affected methods if xxx is defined but xxx_without_a4r is not defined
    # #   Merge aspect definitions
    # #   Recreate xxx that wraps aspects and original method
    # @a4r_data.each do |method, definition|
    #   if existing_aspects[method]
    #     existing_aspects[method].merge!(definition)
    #   else
    #     existing_aspects[method] = (definition.clone rescue definition)
    #   end
    # end
  end
  
  alias included_without_a4r included
  alias included             included_with_a4r
  
  def method_added_with_a4r(method)
    method_added_without_a4r(child) if respond_to?(:method_added_without_a4r)
    
    return if method.to_s =~ /a4r/

    # TODO: alias method to method_without_a4r if advice is defined for method in any of parent class or included module.
    # rename method to method_without_a4r and recreate method if there are advice(s) attached and this is not created by aspect4r
    if not Aspect4r::Helper.creating_method? and @a4r_data and @a4r_data.methods_with_advices.include?(method)
      alias_method Aspect4r::Helper.backup_method_name(method), method
      Aspect4r::Helper.create_method_placeholder self, method
    end
  end
  
  alias method_added_without_a4r method_added
  alias method_added             method_added_with_a4r
end
