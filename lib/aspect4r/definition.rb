module Aspect4r
  class Definition
    BEFORE = 1
    AFTER  = 2
    AROUND = 3
    
    attr_accessor :type, :with_method, :options
    
    def initialize type, with_method, options
      @type        = type
      @with_method = with_method
      @options     = options
    end
    
    %w(before after around).each do |aspect|
      class_eval <<-CODE
        def self.#{aspect} with_method, options = {}
          new #{aspect.upcase}, with_method, options
        end
        
        def #{aspect}? 
          type == #{aspect.upcase}
        end
      CODE
    end
  end
end