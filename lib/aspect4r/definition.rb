module Aspect4r
  class Definition
    BEFORE = 1
    AFTER  = 2
    AROUND = 3
    
    attr_accessor :type, :with_method, :group, :options
    
    def initialize type, with_method, group, options
      @type        = type
      @with_method = with_method
      @group       = group
      @options     = options
    end
    
    %w(before after around).each do |aspect|
      class_eval <<-CODE
        def self.#{aspect} with_method, group, options = {}
          new #{aspect.upcase}, with_method, group, options
        end
        
        def #{aspect}? 
          type == #{aspect.upcase}
        end
      CODE
    end
  end
end