require 'lib/rillow'
require 'lib/rillow_helper'
require 'ruby-debug'

describe Rillow do
  before(:each) do
    @rillow = Rillow.new('X1-ZWz1cqh83mlsej_1y8f9')
    #@rillow.zwsid = 'X1-ZWz1cqh83mlsej_1y8f9'
  end
  
  describe :to_argument do
    it "should be able to convert complicated params to url" do
      to_argument_string = @rillow.send :to_arguments, {'some_thing' => 'else', :more_thing => "fun", "Da-Thing"=>"is it"}
      to_argument_string.should == 'Da-Thing=is+it&more-thing=fun&some-thing=else'
    end
  
  end
  
  describe "zillow methods" do
    it "should be able to give me results even if it doesnt know the sq footage" do
      result = @rillow.get_property_details :address => "955 12th St", :citystatezip => 'Arcata CA 95521'
      result['response'][0]['results'][0]['result'][0]['bedrooms'].to_s.should == "5"
    end
    
    it "should be able to give me results when it does know the sq footage" do
      result = @rillow.get_property_details :address => "4 englewood ave", :citystatezip => 'Worcester MA'
      result['response'][0]['results'][0]['result'][0]['finishedSqFt'].to_s.should == "1744"
    end
    
    it "should be able to do a lookup with just a zipcode and no city or state" do
      result = @rillow.get_property_details :address => "955 12th St", :citystatezip => '95521'
      result['response'][0]['results'][0]['result'][0]['bedrooms'].to_s.should == "5"
    end
    
    
  end
  
end