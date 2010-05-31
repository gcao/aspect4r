module Aspect4r
  class AdviceMetadata
    attr_reader :advice_type, :default_options, :mandatory_options

    def initialize advice_type, default_options = {}, mandatory_options = {}
      @advice_type       = advice_type
      @default_options   = default_options   || {}
      @mandatory_options = mandatory_options || {}
    end
    
    def with_method_prefix
      case advice_type
      when Aspect4r::Advice::BEFORE then "a4r_before_"
      when Aspect4r::Advice::AFTER  then "a4r_after_"
      when Aspect4r::Advice::AROUND then "a4r_around_"
      else raise "Aspect4r internal error."
      end
    end
    
    BEFORE        = new Aspect4r::Advice::BEFORE, nil, :skip_if_false => false
    BEFORE_FILTER = new Aspect4r::Advice::BEFORE, nil, :skip_if_false => true
    AFTER         = new Aspect4r::Advice::AFTER, :result_arg => true
    AROUND        = new Aspect4r::Advice::AROUND
  end
end