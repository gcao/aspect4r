module Aspect4r
  class AspectForMethod
    attr_reader :method, :before_aspects, :after_aspects, :around_aspects
    
    def initialize method
      @method = method
    end
    
    def before_aspects
      @before_aspects ||= []
    end
    
    def after_aspects
      @after_aspects  ||= []
    end
    
    def around_aspects
      @around_aspects ||= []
    end
    
    def around_aspects?
      @around_aspects and not @around_aspects.empty?
    end
    
    def add aspect_definition
      if aspect_definition.before?
        before_aspects << aspect_definition
      elsif aspect_definition.after?
        after_aspects  << aspect_definition
      elsif aspect_definition.around?
        around_aspects << aspect_definition
      end
    end
    
    def empty?
      before_aspects.empty? and after_aspects.empty? and around_aspects.empty?
    end
    
    def + another
      before_aspects.push *another.before_aspects
      after_aspects.push  *another.after_aspects
      around_aspects.push *another.around_aspects
      self
    end
  end
end