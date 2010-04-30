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
          result = if method_name = options[:method]
              send method_name, *args
            else
              yield *(args + [self])
            end

          send new_method, *args if result or not options[:skip_if_false]
        end
      end
    end

    def after_method *methods
      options = {:use_return => false}
      options.merge!(methods.pop) if methods.last.is_a? Hash

      methods.each do |method|
        new_method = Aspect4r::Helper.find_available_method_name self, "#{method}_after_"
        
        alias_method new_method, method
        
        define_method method do |*args|
          result = send new_method, *args
          
          new_result = if method_name = options[:method]
              send method_name, *(args + [result])
            else
              yield *(args + [self, result])
            end
          
          options[:use_return] ? new_result : result
        end
      end
    end

    def around_method *methods, &block
      options = {}
      options.merge!(methods.pop) if methods.last.is_a? Hash

      methods.each do |method|
        new_method = Aspect4r::Helper.find_available_method_name self, "#{method}_around_"

        alias_method new_method, method

        define_method method do |*args|
          if method_name = options[:method]
            send method_name, *(args + [new_method])
          else
            yield *(args + [self, new_method])
          end
        end
      end
    end
  end
end