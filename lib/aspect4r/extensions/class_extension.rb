# TODO: copy over list of methods which have advices
class Class 
  def inherited_with_a4r(child)
    inherited_without_a4r(child) if respond_to?(:inherited_without_a4r, true)
    
    return if @a4r_data.nil? or @a4r_data.empty?

    a4r_data = Aspect4r::Model::AspectData.new
    
    # @a4r_data.each do |key, value|
    #   a4r_data[key] = (value.clone rescue value)
    # end
    
    a4r_data.methods_with_advices.merge(@a4r_data.methods_with_advices)
    
    child.instance_variable_set('@a4r_data', a4r_data)
  end

  alias inherited_without_a4r inherited
  alias inherited             inherited_with_a4r
end
