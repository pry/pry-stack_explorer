require_relative 'test_helper'

describe PryStackExplorer do

  describe "Pry.start" do

    # Given class BingBong...
    class BingBong
      attr_reader :frames, :frame

      def bing; bong; end
      def bong; bang; end
      def bang; Pry.start(binding); end
    end

    let(:bingbong){ BingBong.new }

    before do
      Pry.config.hooks.add_hook(:when_started, :save_caller_bindings, WhenStartedHook)
      Pry.config.hooks.add_hook(:after_session, :delete_frame_manager, AfterSessionHook)

      @o = BingBong.new
    end

    after do
      Pry.config.hooks.delete_hook(:when_started, :save_caller_bindings)
      Pry.config.hooks.delete_hook(:after_session, :delete_frame_manager)
    end

    describe ":initial_frame option" do
      it 'should default to first frame when no option provided' do
        redirect_pry_io(StringIO.new("@frame = __method__\nexit\n"), out=StringIO.new) do
          bingbong.bing
        end

        expect(bingbong.frame).to eq(:bang)
      end

      it 'should begin at correct frame even if Pry.start is monkey-patched (only works with one monkey-patch currently)' do
        class << Pry
          alias_method :old_start, :start

          def start(*args, &block)
            old_start(*args, &block)
          end
        end

        o = BingBong.new

        redirect_pry_io(
          InputTester.new(
            "@frames = SE.frame_manager(pry_instance).bindings.take(3)",
            "exit-all"
          )
        ){ o.bing }

        expect(
          o.frames.map { |f| f.eval("__method__") }
        ).to eq([:bang, :bong, :bing])

        class << Pry
          alias_method :start, :old_start
        end
      end

      it 'should begin session at specified frame' do
        o = Object.new
        class << o; attr_reader :frame; end
        def o.bing() bong end
        def o.bong() bang end
        def o.bang() Pry.start(binding, :initial_frame => 1) end #*

        redirect_pry_io(StringIO.new("@frame = __method__\nexit-all\n"), out=StringIO.new) do
          o.bing
        end

        expect(o.frame).to eq(:bong)
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

        expect(o.frame).to eq(:beta)
      end

      # regression test for #12
      it 'does not infinite loop when pry is started in MyObject#==' do
        o = Object.new
        def o.==(other)
          binding.pry
        end

        redirect_pry_io(InputTester.new(":hello", "exit-all"), out=StringIO.new) do
          o.==(1)
        end

        expect(out.string).to match(/hello/)
      end
    end

    describe ":call_stack option" do
      it 'should invoke a session with the call stack set' do
        redirect_pry_io(StringIO.new("show-stack\nexit\n"), out=StringIO.new) do
          @o.bing
        end

        expect(out.string).to match(/bang.*?bong.*?bing/m)
      end

      it 'should set no call stack when :call_stack => false' do
        o = Object.new
        def o.bing() bong end
        def o.bong() bang end
        def o.bang() Pry.start(binding, :call_stack => false) end

        redirect_pry_io(StringIO.new("show-stack\nexit\n"), out=StringIO.new) do
          o.bing
        end

        expect(out.string).to match(/No caller stack/)
      end

      it 'should set custom call stack when :call_stack => [b1, b2]' do
        o = Object.new
        def o.alpha() binding end
        def o.beta() binding end
        def o.gamma() binding end

        redirect_pry_io(StringIO.new("show-stack\nexit\n"), out=StringIO.new) do
          Pry.start(binding, :call_stack => [o.beta, o.gamma, o.alpha])
        end

        expect(out.string).to match(/beta.*?gamma.*?alpha/m)
      end

      it 'should raise if custom call stack does not contain bindings' do
        o = OpenStruct.new
        redirect_pry_io(StringIO.new("self.errors = pry_instance.hooks.errors\nexit\n")) do
          Pry.start(o, :call_stack => [1, 2, 3])
        end
        expect(o.errors.first.is_a?(ArgumentError)).to eq(true)
      end

      it 'should raise if custom call stack is empty' do
        o = OpenStruct.new
        redirect_pry_io(StringIO.new("self.errors = pry_instance.hooks.errors\nexit\n")) do
          Pry.start o, :call_stack => []
        end
        expect(o.errors.first.is_a?(ArgumentError)).to eq(true)
      end
    end
  end

  describe "class methods" do
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
        expect(PE.frame_manager(@pry_instance).is_a?(PE::FrameManager)).to eq(true)
        expect(PE.frame_managers(@pry_instance).count).to eq(1)
      end

      it "should refresh Pry instance to use FrameManager's active binding" do
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        expect(@pry_instance.binding_stack.size).to eq(1)
        expect(@pry_instance.binding_stack.first).to eq(@bindings.first)
      end

      it 'should save prior binding in FrameManager instance' do
        _pry_ = Pry.new
        _pry_.binding_stack.push(b=binding)
        PryStackExplorer.create_and_push_frame_manager(@bindings, _pry_)
        expect(PryStackExplorer.frame_manager(_pry_).prior_binding).to eq(b)
      end

      describe ":initial_frame option" do
        it 'should start on specified frame' do
          PE.create_and_push_frame_manager(@bindings, @pry_instance, :initial_frame => 1)
          expect(@pry_instance.binding_stack.size).to eq(1)
          expect(@pry_instance.binding_stack.first).to eq(@bindings.last)
        end

        describe "negative numbers" do
          it 'should work with negative frame number (-1)' do
            PE.create_and_push_frame_manager(@bindings, @pry_instance, :initial_frame => -1)
            expect(@pry_instance.binding_stack.size).to eq(1)
            expect(@pry_instance.binding_stack.first).to eq(@bindings.last)
          end

          it 'should work with negative frame number (-2)' do
            PE.create_and_push_frame_manager(@bindings, @pry_instance, :initial_frame => -2)
            expect(@pry_instance.binding_stack.size).to eq(1)
            expect(@pry_instance.binding_stack.first).to eq(@bindings.first)
          end
        end
      end

      it 'should save prior backtrace in FrameManager instance' do
        _pry_ = Pry.new
        _pry_.backtrace = ["my backtrace"]
        PryStackExplorer.create_and_push_frame_manager(@bindings, _pry_)
        expect(PryStackExplorer.frame_manager(_pry_).prior_backtrace).to eq(_pry_.backtrace)
      end

      it  "should create and push multiple FrameManagers" do
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        expect(PE.frame_managers(@pry_instance).count).to eq(2)
      end

      it 'should push FrameManagers to stacks based on Pry instance' do
        p2 = Pry.new
        bindings = [binding, binding]
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        PE.create_and_push_frame_manager(bindings, p2)
        expect(PE.frame_managers(@pry_instance).count).to eq(1)
        expect(PE.frame_managers(p2).count).to eq(1)
      end
    end

    describe "PryStackExplorer.frame_manager" do
      it  "should have the correct bindings" do
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        expect(PE.frame_manager(@pry_instance).bindings).to eq(@bindings)
      end

      it "should return the last pushed FrameManager" do
        bindings = [binding, binding]
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        PE.create_and_push_frame_manager(bindings, @pry_instance)
        expect(PE.frame_manager(@pry_instance).bindings).to eq(bindings)
      end

      it "should return the correct FrameManager for the given Pry instance" do
        bindings = [binding, binding]
        p2 = Pry.new
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        PE.create_and_push_frame_manager(bindings, p2)
        expect(PE.frame_manager(@pry_instance).bindings).to eq(@bindings)
        expect(PE.frame_manager(p2).bindings).to eq(bindings)
      end
    end

    describe "PryStackExplorer.pop_frame_manager" do
      it "should remove FrameManager from stack" do
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        PE.pop_frame_manager(@pry_instance)
        expect(PE.frame_managers(@pry_instance).count).to eq(1)
      end

      it "should return the most recently added FrameManager" do
        bindings = [binding, binding]
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        PE.create_and_push_frame_manager(bindings, @pry_instance)
        expect(PE.pop_frame_manager(@pry_instance).bindings).to eq(bindings)
      end

      it "should remove FrameManager from the appropriate stack based on Pry instance" do
        p2 = Pry.new
        bindings = [binding, binding]
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        PE.create_and_push_frame_manager(bindings, p2)
        PE.pop_frame_manager(@pry_instance)
        expect(PE.frame_managers(@pry_instance).count).to eq(0)
        expect(PE.frame_managers(p2).count).to eq(1)
      end

      it "should remove key when no frames remaining for Pry instance" do
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        PE.pop_frame_manager(@pry_instance)
        PE.pop_frame_manager(@pry_instance)
        expect(PE.frame_hash.has_key?(@pry_instance)).to eq(false)
      end

      it 'should not change size of binding_stack when popping' do
        bindings = [bindings, bindings]
        PE.create_and_push_frame_manager(bindings, @pry_instance)
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        PE.pop_frame_manager(@pry_instance)
        expect(@pry_instance.binding_stack.size).to eq(1)
      end

      it 'should return nil when popping non-existent frame manager' do
        expect(PE.pop_frame_manager(@pry_instance)).to eq(nil)
      end

      describe "restoring previous binding" do
        it 'should restore previous binding for Pry instance on pop, where previous binding is not first frame' do
          bindings = [binding, binding]
          PE.create_and_push_frame_manager(bindings, @pry_instance).binding_index = 1
          PE.create_and_push_frame_manager(@bindings, @pry_instance)
          PE.pop_frame_manager(@pry_instance)
          expect(@pry_instance.binding_stack.first).to eq(bindings[1])
        end

        it 'should restore previous binding for Pry instance on pop (previous frame frame manager)' do
          bindings = [binding, binding]
          PE.create_and_push_frame_manager(bindings, @pry_instance)
          PE.create_and_push_frame_manager(@bindings, @pry_instance)
          PE.pop_frame_manager(@pry_instance)
          expect(@pry_instance.binding_stack.first).to eq(bindings.first)
        end

        it 'should restore previous binding for Pry instance on pop (no previous frame manager)' do
          b = binding
          @pry_instance.binding_stack = [b]
          PE.create_and_push_frame_manager(@bindings, @pry_instance)
          PE.pop_frame_manager(@pry_instance)
          expect(@pry_instance.binding_stack.first).to eq(b)
        end

        it 'should restore previous binding for Pry instance on pop (no previous frame manager AND no empty binding_stack)' do
          b = binding
          @pry_instance.binding_stack = [b]
          PE.create_and_push_frame_manager(@bindings, @pry_instance)
          @pry_instance.binding_stack.clear
          PE.pop_frame_manager(@pry_instance)
          expect(@pry_instance.binding_stack.first).to eq(b)
        end
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
          expect(p1.backtrace).to eq("my backtrace2")
          PE.pop_frame_manager(p1)
          expect(p1.backtrace).to eq("my backtrace1")
        end
      end
    end

    describe "PryStackExplorer.clear_frame_managers" do
      it "should clear all FrameManagers for a Pry instance" do
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        PE.clear_frame_managers(@pry_instance)
        expect(PE.frame_hash.has_key?(@pry_instance)).to eq(false)
      end

      it "should clear all FrameManagers for a Pry instance but leave others untouched" do
        p2 = Pry.new
        bindings = [binding, binding]
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        PE.create_and_push_frame_manager(bindings, p2)
        PE.clear_frame_managers(@pry_instance)
        expect(PE.frame_managers(p2).count).to eq(1)
        expect(PE.frame_hash.has_key?(@pry_instance)).to eq(false)
      end

      it "should remove key" do
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        PE.create_and_push_frame_manager(@bindings, @pry_instance)
        PE.clear_frame_managers(@pry_instance)
        expect(PE.frame_hash.has_key?(@pry_instance)).to eq(false)
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
          expect(p1.backtrace).to eq("my backtrace1")
        end
      end
    end
  end
end
