class Class 
  def inherited_with_aspect4r(child)
    inherited_without_aspect4r(child) if respond_to?(:inherited_without_aspect4r, true)
    
    return if @a4r_definitions.nil? or @a4r_definitions.empty?
  
    a4r_definitions = @a4r_definitions.inject({}) do |memo, (key, value)|
      memo[key] = (value.clone rescue value)
      memo
    end
    
    child.instance_variable_set('@a4r_definitions', a4r_definitions)
  end

  alias inherited_without_aspect4r inherited
  alias inherited                  inherited_with_aspect4r
end