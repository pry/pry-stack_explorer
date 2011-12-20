require 'helper'

describe PryStackExplorer do

  before do
    @pry_instance = Pry.new
    @bindings = [binding, binding]
  end

  after do
    PE.clear_frame_managers(@pry_instance)
  end

  it  "should create and push one new FrameManager" do
    PE.create_and_push_frame_manager(@bindings, @pry_instance)
    PE.frame_manager(@pry_instance).is_a?(PE::FrameManager).should == true
    PE.all_frame_managers(@pry_instance).count.should == 1
  end

  it  "should have the correct bindings" do
    PE.create_and_push_frame_manager(@bindings, @pry_instance)
    PE.frame_manager(@pry_instance).bindings.should == @bindings
  end

  it "should pop a FrameManager" do
    PE.create_and_push_frame_manager(@bindings, @pry_instance)
    PE.create_and_push_frame_manager(@bindings, @pry_instance)
    PE.pop_frame_manager(@pry_instance)
    PE.all_frame_managers(@pry_instance).count.should == 1
  end

  it "should clear all FrameManagers for a Pry instance" do
    PE.create_and_push_frame_manager(@bindings, @pry_instance)
    PE.create_and_push_frame_manager(@bindings, @pry_instance)
    PE.clear_frame_managers(@pry_instance)
    PE.all_frame_managers(@pry_instance).count.should == 0
  end
end

