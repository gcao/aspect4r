class Module
  # def include_with_a4r *modules
  #   # Rename xxx to xxx_without_a4r if advices are added in any module
  #   a4r_definitions = {}
  #   modules.each do |mod|
  #     definitions = mod.instance_variable_get :@a4r_definitions
  #     
  #   end
  #   include_without_a4r *modules
  # end
  # 
  # alias include_without_a4r include
  # alias include             include_with_a4r

  def included_with_a4r(base)
    included_without_a4r(child) if respond_to?(:included_without_a4r)
    
    return if @a4r_definitions.nil? or @a4r_definitions.empty?

    base.send(:include, Aspect4r)
    
    existing_aspects = base.a4r_definitions
    
    # For each method in a4r_definitions of INCLUDED module
    #   Backup xxx as xxx_without_a4r for each affected methods if xxx is defined but xxx_without_a4r is not defined
    #   Merge aspect definitions
    #   Recreate xxx that wraps aspects and original method
    @a4r_definitions.each do |method, definition|
      if existing_aspects[method]
        existing_aspects[method].merge!(definition)
      else
        Aspect4r::Helper.backup_original_method base, method
        existing_aspects[method] = (definition.clone rescue definition)
      end
      
      Aspect4r::Helper.create_method_placeholder base, method
    end
  end
  
  alias included_without_a4r included
  alias included             included_with_a4r
  
  def method_added_with_a4r(method)
    method_added_without_a4r(child) if respond_to?(:method_added_without_a4r)
    
    return if method.to_s =~ /a4r/
    
    # rename method to method_without_a4r and recreate method if there are advice(s) attached and this is not created by aspect4r
    unless Aspect4r::Helper.creating_method?
      if @a4r_definitions and @a4r_definitions[method.to_s]
        alias_method method, Aspect4r::Helper.backup_method_name(method)
        Aspect4r::Helper.create_method_placeholder self, method
      end
    end
  end
  
  alias method_added_without_a4r method_added
  alias method_added             method_added_with_a4r
end
