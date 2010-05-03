require 'aspect4r/helper'

module Aspect4r
  def self.included(base)
     base.extend(ClassMethods)
  end

  module ClassMethods
    def before_method *methods
      options = {:skip_if_false => false}
      options.merge!(methods.pop) if methods.last.is_a? Hash

      methods.each do |method|
        new_method = Aspect4r::Helper.find_available_method_name self, "#{method}_before_"
        
        alias_method new_method, method
        
        define_method method do |*args|
          result = if block_given? 
              yield *([self] + args)
            else
              m = options[:method] || :"before_#{method}"
              send m, *args
            end

          send new_method, *args if result or not options[:skip_if_false]
        end
      end
    end
    
    def before_method_check *methods
      options = methods.last.is_a?(Hash) ? methods.pop : {}
      options.merge! :skip_if_false => true
      before_method *(methods + [options])
    end

    def after_method *methods
      options = {:use_return => false}
      options.merge!(methods.pop) if methods.last.is_a? Hash

      methods.each do |method|
        new_method = Aspect4r::Helper.find_available_method_name self, "#{method}_after_"
        
        alias_method new_method, method
        
        define_method method do |*args|
          result = send new_method, *args
          
          new_result = if block_given?
              yield *([self, result] + args)
            else
              m = options[:method] || :"after_#{method}"
              send m, *([result] + args)
            end
          
          options[:use_return] ? new_result : result
        end
      end
    end
    
    def after_method_process *methods
      options = methods.last.is_a?(Hash) ? methods.pop : {}
      options.merge! :use_return => true
      after_method *(methods + [options])
    end

    def around_method *methods, &block
      options = {}
      options.merge!(methods.pop) if methods.last.is_a? Hash

      methods.each do |method|
        new_method = Aspect4r::Helper.find_available_method_name self, "#{method}_around_"

        alias_method new_method, method

        define_method method do |*args|
          if block_given?
            yield *([self, new_method] + args)
          else
            m = options[:method] || :"around_#{method}"
            send m, *([new_method] + args)
          end
        end
      end
    end
  end
end