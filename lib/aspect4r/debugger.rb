module Aspect4r
  class Debugger    
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
  end
  
  def self.debug klass_or_module, *methods
    @debug_info ||= {}

    methods.each do |method|
      debugger = @debug_info[debug_key(klass_or_module, method)] = Debugger.new(klass_or_module, method)
      debugger.add_meta "Enabled debug mode for #{debugger.target}"
    end
  end
  
  def self.debug_end klass_or_module, *methods
    return unless @debug_info
    
    methods.each do |method|
      key = debug_key(klass_or_module, method)
      
      debugger = @debug_info[key]
      debugger.add_meta("Disabled debug mode for #{debugger.target}")
      
      @debug_info.delete key
    end

    @debug_info = nil if @debug_info.empty?
  end
  
  def self.debugger klass_or_module, method
    @debug_info and @debug_info[debug_key(klass_or_module, method)]
  end
  
  private
  
  def self.debug_key klass_or_module, method
    "#{klass_or_module.hash}:#{method}"
  end
end
