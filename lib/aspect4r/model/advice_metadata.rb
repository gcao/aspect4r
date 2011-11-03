module Aspect4r
  module Model
    class AdviceMetadata
      attr_reader :advice_type, :default_options, :mandatory_options

      def initialize advice_type, default_options = {}, mandatory_options = {}
        @advice_type       = advice_type
        @default_options   = default_options   || {}
        @mandatory_options = mandatory_options || {}
      end

      def with_method_prefix
        case advice_type
        when Aspect4r::Model::Advice::BEFORE then "a4r_before_"
        when Aspect4r::Model::Advice::AFTER  then "a4r_after_"
        when Aspect4r::Model::Advice::AROUND then "a4r_around_"
        else raise "Aspect4r internal error."
        end
      end

      BEFORE        = new Aspect4r::Model::Advice::BEFORE, { :new_methods_only => true }, :skip_if_false => false
      BEFORE_FILTER = new Aspect4r::Model::Advice::BEFORE, { :new_methods_only => true }, :skip_if_false => true
      AFTER         = new Aspect4r::Model::Advice::AFTER,  { :new_methods_only => true, :result_arg => true }
      AROUND        = new Aspect4r::Model::Advice::AROUND, { :new_methods_only => true }
    end
  end
end
