require 'aspect4r/before'
require 'aspect4r/after'
require 'aspect4r/around'

module Aspect4r
  module Classic
    def self.included(base)
      base.send(:include, Before::Classic, After::Classic, Around::Classic)
    end
  end
end