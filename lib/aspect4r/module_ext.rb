class Module
  def included_with_aspect4r(base)
    included_without_aspect4r(child) if respond_to?(:included_without_aspect4r)
    
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
  
  alias included_without_aspect4r included
  alias included                  included_with_aspect4r
end
