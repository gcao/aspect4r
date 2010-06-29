module Aspect4r
  
  def self.event_handler
    @event_handler
  end
  
  def self.event_handler= event_handler
    @event_handler = event_handler
  end
    
  class Event
    ADVICE_CREATION = 'advice_creation'
    METHOD_CREATION = 'method_creation'
    EXECUTION_BEGIN = 'execution_begin'
    EXECUTION_END   = 'execution_end'
    ADVICE_BEGIN    = 'advice_begin'
    ADVICE_END      = 'advice_end'
    METHOD_BEGIN    = 'method_begin'
    METHOD_END      = 'method_end'
    
    attr_reader :name, :data
    
    def initialize name, data = {}
      @name = name.to_s
      @data = data
    end
    
    # Delegate method to data
    def method_missing method
      data[method] or data[method.to_s]
    end
  end
  
  class EventHandler
    def respond_to? klass_or_module, method = nil
      false
    end
    
    def handle event
    end
  end
end
