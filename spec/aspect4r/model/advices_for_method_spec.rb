# require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
# 
# describe Aspect4r::Model::AdvicesForMethod do
#   it "should be able to get advice by name" do
#     advices = Aspect4r::Model::AdvicesForMethod.new(:test)
#     advice1 = Aspect4r::Model::Advice.new Aspect4r::Model::Advice::BEFORE, :advice_method, :group, :name => :advice1
#     advices.add advice1
#     advices[:advice1].should == advice1
#   end
#   
#   it "should be able to get advice by name String" do
#     advices = Aspect4r::Model::AdvicesForMethod.new(:test)
#     advice1 = Aspect4r::Model::Advice.new Aspect4r::Model::Advice::BEFORE, :advice_method, :group, :name => :advice1
#     advices.add advice1
#     advices['advice1'].should == advice1
#   end
# end