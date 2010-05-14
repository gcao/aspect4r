class Module
  private
  
  def included_with_aspect4r(base)
    included_without_aspect4r(child) if respond_to?(:included_without_aspect4r)
    
    return if @a4f_definitions.nil? or @a4r_definitions.empty?
    
    base.send(:include, Aspect4r)
    
    a4r_definitions = 
      if @a4r_definitions.nil?
        {}
      else
        @a4r_definitions.inject({}) do |memo,(key, value)|
          memo.update(key => (value.dup rescue value))
        end
      end
    
    # TODO merge aspect definitions
  end
  
  alias included_without_aspect4r included
  alias included                  included_with_aspect4r
end