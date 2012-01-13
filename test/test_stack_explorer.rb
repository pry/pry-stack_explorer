require 'helper'

describe PryStackExplorer do

  describe "Pry.start" do
    before do
      Pry.config.hooks.add_hook(:when_started, :save_caller_bindings, &WhenStartedHook)
      Pry.config.hooks.add_hook(:after_session, :delete_frame_manager, &AfterSessionHook)

      @o = Object.new
      class << @o; attr_reader :frame; end
      def @o.bing() bong end
      def @o.bong() bang end
      def @o.bang() Pry.start(binding) end
    end

    after do
      Pry.config.hooks.delete_hook(:when_started, :save_caller_bindings)
      Pry.config.hooks.delete_hook(:after_session, :delete_frame_manager)
    end

    describe ":initial_frame option" do
      it 'should default to first frame when no option provided' do
        redirect_pry_io(StringIO.new("@frame = __method__\nexit\n"), out=StringIO.new) do
          @o.bing
        end

        @o.frame.should == :bang
      end

      it 'should begin session at specified frame' do
        o = Object.new
        class << o; attr_reader :frame; end
        def o.bing() bong end
        def o.bong() bang end
        def o.bang() Pry.start(binding, :initial_frame => 1) end

        redirect_pry_io(StringIO.new("@frame = __method__\nexit\n"), out=StringIO.new) do
          o.bing
        end

        o.frame.should == :bong
      end

      it 'should begin session at specified frame when using :call_stack' do
        o = Object.new
        class << o; attr_accessor :frame; end
        def o.alpha() binding end
        def o.beta() binding end
        def o.gamma() binding end

        redirect_pry_io(StringIO.new("@frame = __method__\nexit\n"), out=StringIO.new) do
          Pry.start(binding, :call_stack => [o.gamma, o.beta, o.alpha], :initial_frame => 1)
        end

        o.frame.should == :beta
      end

    end

    describe ":call_stack option" do
      it 'should invoke a session with the call stack set' do
        redirect_pry_io(StringIO.new("show-stack\nexit\n"), out=StringIO.new) do
          @o.bing
        end

        out.string.should =~ /bang.*?bong.*?bing/m
      end

      it 'should set no call stack when :call_stack => false' do
        o = Object.new
        def o.bing() bong end
        def o.bong() bang end
        def o.bang() Pry.start(binding, :call_stack => false) end

        redirect_pry_io(StringIO.new("show-stack\nexit\n"), out=StringIO.new) do
          o.bing
        end

        out.string.should =~ /No caller stack/
      end

      it 'should set custom call stack when :call_stack => [b1, b2]' do
        o = Object.new
        def o.alpha() binding end
        def o.beta() binding end
        def o.gamma() binding end

        redirect_pry_io(StringIO.new("show-stack\nexit\n"), out=StringIO.new) do
          Pry.start(binding, :call_stack => [o.beta, o.gamma, o.alpha])
        end

        out.string.should =~ /beta.*?gamma.*?alpha/m
      end

      it 'should raise if custom call stack does not contain bindings or is empty' do
        redirect_pry_io(StringIO.new("show-stack\nexit\n"), out=StringIO.new) do
          lambda { Pry.start(binding, :call_stack => [1, 2, 3]) }.should.raise ArgumentError
        end

        redirect_pry_io(StringIO.new("show-stack\nexit\n"), out=StringIO.new) do
          lambda { Pry.start(binding, :call_stack => []) }.should.raise ArgumentError
        end
      end
    end
  end

  describe "unit tests for PryStackExplorer class methods" do
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
        PE.frame_managers(@pry_instance).count.should == 1
      end

      it 'should save prior binding in FrameManager instance' do
        _pry_ = Pry.new
        _pry_.binding_stack.push(b=binding)
        PryStackExplorer.create_and_push_frame_manager(@bindings, _pry_)
        PryStackExplorer.frame_manager(_pry_).prior_binding.should == b
      end

      it  "should create and push multiple FrameManagers" do
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        PE.frame_managers(@pry_instance).count.should == 2
      end

      it 'should push FrameManagers to stacks based on Pry instance' do
        p2 = Pry.new
        bindings = [binding, binding]
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        PE.create_and_push_frame_manager(bindings, p2)
        PE.frame_managers(@pry_instance).count.should == 1
        PE.frame_managers(p2).count.should == 1
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
        PE.frame_managers(@pry_instance).count.should == 1
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
        PE.frame_managers(@pry_instance).count.should == 0
        PE.frame_managers(p2).count.should == 1
      end

      it "should remove key when no frames remaining for Pry instance" do
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        PE.pop_frame_manager(@pry_instance)
        PE.pop_frame_manager(@pry_instance)
        PE.frame_hash.has_key?(@pry_instance).should == false
      end

      describe "_pry_.backtrace" do
        it "should restore backtrace when frame is popped" do
          p1 = Pry.new
          bindings = [binding, binding]
          p1.backtrace = "my backtrace1"
          PE.create_and_push_frame_manager(bindings, p1)
          p1.backtrace = "my backtrace2"
          PE.create_and_push_frame_manager(bindings, p1)
          p1.backtrace = "my backtrace3"

          PE.pop_frame_manager(p1)
          p1.backtrace.should == "my backtrace2"
          PE.pop_frame_manager(p1)
          p1.backtrace.should == "my backtrace1"
        end
      end
    end

    describe "PryStackExplorer.clear_frame_managers" do
      it "should clear all FrameManagers for a Pry instance" do
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        PE.clear_frame_managers(@pry_instance)
        PE.frame_hash.has_key?(@pry_instance).should == false
      end

      it "should clear all FrameManagers for a Pry instance but leave others untouched" do
        p2 = Pry.new
        bindings = [binding, binding]
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        PE.create_and_push_frame_manager(bindings, p2)
        PE.clear_frame_managers(@pry_instance)
        PE.frame_managers(p2).count.should == 1
        PE.frame_hash.has_key?(@pry_instance).should == false
      end

      it "should remove key" do
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        PE.clear_frame_managers(@pry_instance)
        PE.frame_hash.has_key?(@pry_instance).should == false
      end

      describe "_pry_.backtrace" do
        it "should restore backtrace to initial one when frame managers are cleared" do
          p1 = Pry.new
          bindings = [binding, binding]
          p1.backtrace = "my backtrace1"
          PE.create_and_push_frame_manager(bindings, p1)
          p1.backtrace = "my backtrace2"
          PE.create_and_push_frame_manager(bindings, p1)
          p1.backtrace = "my backtrace3"

          PE.clear_frame_managers(p1)
          p1.backtrace.should == "my backtrace1"
        end
      end

    end
  end
end
