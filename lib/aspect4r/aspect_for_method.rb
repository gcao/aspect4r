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
    
    def before_aspects?
      @before_aspects and not @before_aspects.empty?
    end
    
    def after_aspects?
      @after_aspects and not @after_aspects.empty?
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
      not (before_aspects? or after_aspects? or around_aspects?)
    end
    
    def merge! another
      before_aspects.push *another.before_aspects if another.before_aspects?
      after_aspects.push  *another.after_aspects  if another.after_aspects?
      around_aspects.push *another.around_aspects if another.around_aspects?
      self
    end
    
    def clone
      o = AspectForMethod.new(method)
      
      if before_aspects?
        before_aspects.each do |definition|
          o.before_aspects << definition
        end
      end
      
      if after_aspects?
        after_aspects.each do |definition|
          o.after_aspects << definition
        end
      end
      
      if around_aspects?
        around_aspects.each do |definition|
          o.around_aspects << definition
        end
      end
      
      o
    end
  end
end