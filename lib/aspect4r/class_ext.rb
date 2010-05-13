class Class 
  private
  
  def inherited_with_aspect4r(child)
    inherited_without_aspect4r(child) if respond_to?(:inherited_without_aspect4r)
  
    a4r_definitions = 
      if @a4r_definitions.nil?
        {}
      else
        @a4r_definitions.inject({}) do |memo,(key, value)|
          memo.update(key => (value.dup rescue value))
        end
      end
    
    child.instance_variable_set('@a4r_definitions', a4r_definitions)
  end

  alias inherited_without_aspect4r inherited
  alias inherited                  inherited_with_aspect4r
end