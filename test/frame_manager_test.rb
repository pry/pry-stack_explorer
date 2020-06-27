require_relative 'test_helper'

describe PryStackExplorer::FrameManager do
  before :all do
    redirect_pry_output!
  end

  before do
    @pry_instance = Pry.new
    @bindings = [binding, binding, binding, binding]
    @bindings.each_with_index { |v, i| v.eval("x = #{i}") }
    @pry_instance.binding_stack.push @bindings.last
    @frame_manager = PE::FrameManager.new(@bindings, @pry_instance)
  end

  describe "creation" do
    it "should make bindings accessible via 'bindings' method" do
      expect(@frame_manager.bindings).to eq(@bindings)
    end

    it "should set binding_index to 0" do
      expect(@frame_manager.binding_index).to eq(0)
    end

    it "should set current_frame to first frame" do
      expect(@frame_manager.current_frame).to eq(@bindings.first)
    end
  end

  describe "FrameManager#change_frame_to" do
    it 'should change the frame to the given one' do
      @frame_manager.change_frame_to(1)

      expect(@frame_manager.binding_index).to eq(1)
      expect(@frame_manager.current_frame).to eq(@bindings[1])
      expect(@pry_instance.binding_stack.last).to eq(@frame_manager.current_frame)
    end

    it 'should accept negative indices when specifying frame' do
      @frame_manager.change_frame_to(-1)

      # negative index is converted to a positive one inside change_frame_to
      expect(@frame_manager.binding_index).to eq(@bindings.size - 1)
      expect(@frame_manager.current_frame).to eq(@bindings[-1])
      expect(@pry_instance.binding_stack.last).to eq(@frame_manager.current_frame)
    end
  end

  describe "FrameManager#refresh_frame" do
    it 'should change the Pry frame to the active one in the FrameManager' do
      @frame_manager.binding_index = 2
      @frame_manager.refresh_frame

      expect(@pry_instance.binding_stack.last).to eq(@frame_manager.current_frame)
    end
  end

  describe "FrameManager is Enumerable" do
    it 'should perform an Enumerable#map on the frames' do
      result = @frame_manager.map { |v| v.eval("x") }

      expect(result).to eq(
        (0..(@bindings.size - 1)).to_a
      )
    end
  end

end
