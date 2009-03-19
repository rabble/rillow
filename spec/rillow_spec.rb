require 'lib/rillow'
require 'lib/rillow_helper'

describe Rillow do
  before(:each) do
    @rillow = Rillow.new('X1-ZWz1cqh83mlsej_1y8f9')
  end
  
  describe :to_argument do
    it "should be able to convert complicated params to url" do
      to_argument_string = @rillow.send :to_arguments, {'some_thing' => 'else', :more_thing => "fun", "Da-Thing"=>"is it"}
      to_argument_string.should == 'Da_Thing=is+it&more_thing=fun&some_thing=else'
    end
  
  end
end