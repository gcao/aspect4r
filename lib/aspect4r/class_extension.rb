class Class 
  def inherited_with_a4r(child)
    inherited_without_a4r(child) if respond_to?(:inherited_without_a4r, true)
    
    return if @a4r_data.nil? or @a4r_data.empty?
  
    a4r_data = @a4r_data.inject({}) do |memo, (key, value)|
      memo[key] = (value.clone rescue value)
      memo
    end
    
    child.instance_variable_set('@a4r_data', a4r_data)
  end

  alias inherited_without_a4r inherited
  alias inherited             inherited_with_a4r
end
