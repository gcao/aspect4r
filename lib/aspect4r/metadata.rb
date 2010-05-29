module Aspect4r
  class Metadata
    attr_reader :advice_type, :default_options, :mandatory_options

    def initialize advice_type, default_options = {}, mandatory_options = {}
      @advice_type       = advice_type
      @default_options   = default_options   || {}
      @mandatory_options = mandatory_options || {}
    end
    
    def with_method_prefix
      case advice_type
      when Aspect4r::Definition::BEFORE then "a4r_before_"
      when Aspect4r::Definition::AFTER  then "a4r_after_"
      when Aspect4r::Definition::AROUND then "a4r_around_"
      else raise "Aspect4r internal error."
      end
    end
    
    BEFORE        = new Aspect4r::Definition::BEFORE
    BEFORE_FILTER = new Aspect4r::Definition::BEFORE, nil, :skip_if_false => true
    AFTER         = new Aspect4r::Definition::AFTER
    AROUND        = new Aspect4r::Definition::AROUND
  end
end