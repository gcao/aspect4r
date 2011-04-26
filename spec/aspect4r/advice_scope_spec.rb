require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Aspect4r do
  it "should limit changes to module that includes Aspect4r" do
    module ScopeParent
      include Aspect4r
    end
    
    module ScopeChild
      include ScopeParent
    end
    
    ScopeChild.methods.should_not include('a4r_data')
  end
end