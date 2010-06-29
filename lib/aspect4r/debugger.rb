module Aspect4r
  class Debugger < Aspect4r::EventHandler
    attr :klass_or_module
    attr :method
    
    def initialize klass_or_module, method
      @klass_or_module = klass_or_module
      @method          = method.to_s
    end
    
    def add message
      puts "a4r #{target}: #{message}"
    end
    
    def add_meta message
      add "* #{message}"
    end
    
    def target
      name = @klass_or_module.name
      name = "Anonymous" if name.empty?
      
      "#{name}##{@method}"
    end
    
    # Overwrite method in EventHandler
    def respond_to? klass_or_module, method
      false
    end
    
    # Overwrite method in EventHandler
    def handle event
      case event
      when Event::ADVICE_CREATION
      when Event::METHOD_CREATION
      end
    end
  end
  
  def self.debug klass_or_module, *methods
    @debug_info ||= {}

    methods.each do |method|
      debugger = @debug_info[debug_key(klass_or_module, method)] = Debugger.new(klass_or_module, method)
      debugger.add_meta "Enabled debug mode for #{debugger.target}"
      # TODO show advices defined already
      # recreate method with advices
      aspect = klass_or_module.a4r_data[method]
      Aspect4r::Helper.create_method klass_or_module, method if aspect and aspect.wrapped_method
    end
  end
  
  def self.debug_end
    return unless @debug_info
    
    @debug_info.each do |key, debugger|
      debugger.add_meta("Disabled debug mode for #{debugger.target}")
      # remove debugger and recreate method
      @debug_info.delete(key)
      aspect = debugger.klass_or_module.a4r_data[debugger.method]
      Aspect4r::Helper.create_method debugger.klass_or_module, debugger.method if aspect and aspect.wrapped_method
    end

    @debug_info = nil
  end
  
  def self.debugger klass_or_module, method
    @debug_info and @debug_info[debug_key(klass_or_module, method)]
  end
  
  private
  
  def self.debug_key klass_or_module, method
    "#{klass_or_module.hash}:#{method}"
  end
end
