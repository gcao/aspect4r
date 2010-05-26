module Aspect4r
  class AspectForMethod
    attr_reader :method
    
    def initialize method
      @method = method
    end
    
    def advices
      @advices ||= []
    end
    
    def add aspect_definition
      advices << aspect_definition
    end
    
    def empty?
      @advices.nil? or @advices.empty?
    end
    
    def merge! another
      advices.push *another.advices unless another.empty?
      self
    end
    
    def clone
      o = AspectForMethod.new(method)
      o.advices.push *advices unless empty?

      o
    end
  end
end