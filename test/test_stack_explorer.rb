require 'helper'

describe PryStackExplorer do

  before do
    @pry_instance = Pry.new
    @bindings = [binding, binding]
  end

  after do
    PE.clear_frame_managers(@pry_instance)
  end

  describe "PryStackExplorer.create_and_push_frame_manager" do
    it  "should create and push one new FrameManager" do
      PE.create_and_push_frame_manager(@bindings, @pry_instance)
      PE.frame_manager(@pry_instance).is_a?(PE::FrameManager).should == true
      PE.all_frame_managers(@pry_instance).count.should == 1
    end

    it  "should create and push multiple FrameManagers" do
      PE.create_and_push_frame_manager(@bindings, @pry_instance)
      PE.create_and_push_frame_manager(@bindings, @pry_instance)
      PE.all_frame_managers(@pry_instance).count.should == 2
    end

    it 'should push FrameManagers to stacks based on Pry instance' do
      p2 = Pry.new
      bindings = [binding, binding]
      PE.create_and_push_frame_manager(@bindings, @pry_instance)
      PE.create_and_push_frame_manager(bindings, p2)
      PE.all_frame_managers(@pry_instance).count.should == 1
      PE.all_frame_managers(p2).count.should == 1
    end
  end

  describe "PryStackExplorer.frame_manager" do
    it  "should have the correct bindings" do
      PE.create_and_push_frame_manager(@bindings, @pry_instance)
      PE.frame_manager(@pry_instance).bindings.should == @bindings
    end

    it "should return the last pushed FrameManager" do
      bindings = [binding, binding]
      PE.create_and_push_frame_manager(@bindings, @pry_instance)
      PE.create_and_push_frame_manager(bindings, @pry_instance)
      PE.frame_manager(@pry_instance).bindings.should == bindings
    end

    it "should return the correct FrameManager for the given Pry instance" do
      bindings = [binding, binding]
      p2 = Pry.new
      PE.create_and_push_frame_manager(@bindings, @pry_instance)
      PE.create_and_push_frame_manager(bindings, p2)
      PE.frame_manager(@pry_instance).bindings.should == @bindings
      PE.frame_manager(p2).bindings.should == bindings
    end
  end

  describe "PryStackExplorer.pop_frame_manager" do
    it "should remove FrameManager from stack" do
      PE.create_and_push_frame_manager(@bindings, @pry_instance)
      PE.create_and_push_frame_manager(@bindings, @pry_instance)
      PE.pop_frame_manager(@pry_instance)
      PE.all_frame_managers(@pry_instance).count.should == 1
    end

    it "should return the most recently added FrameManager" do
      bindings = [binding, binding]
      PE.create_and_push_frame_manager(@bindings, @pry_instance)
      PE.create_and_push_frame_manager(bindings, @pry_instance)
      PE.pop_frame_manager(@pry_instance).bindings.should == bindings
    end

    it "should remove FrameManager from the appropriate stack based on Pry instance" do
      p2 = Pry.new
      bindings = [binding, binding]
      PE.create_and_push_frame_manager(@bindings, @pry_instance)
      PE.create_and_push_frame_manager(bindings, p2)
      PE.pop_frame_manager(@pry_instance)
      PE.all_frame_managers(@pry_instance).count.should == 0
      PE.all_frame_managers(p2).count.should == 1
    end
  end

  describe "PryStackExplorer.clear_frame_managers" do
    it "should clear all FrameManagers for a Pry instance" do
      PE.create_and_push_frame_manager(@bindings, @pry_instance)
      PE.create_and_push_frame_manager(@bindings, @pry_instance)
      PE.clear_frame_managers(@pry_instance)
      PE.all_frame_managers(@pry_instance).count.should == 0
    end

    it "should clear all FrameManagers for a Pry instance" do
      p2 = Pry.new
      bindings = [binding, binding]
      PE.create_and_push_frame_manager(@bindings, @pry_instance)
      PE.create_and_push_frame_manager(bindings, p2)
      PE.clear_frame_managers(@pry_instance)
      PE.all_frame_managers(p2).count.should == 1
      PE.all_frame_managers(@pry_instance).count.should == 0
    end
  end
end

