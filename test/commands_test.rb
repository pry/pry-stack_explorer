require_relative 'test_helper'

class Top
  attr_accessor :method_list, :middle
  def initialize method_list
    @method_list = method_list
  end
  def bing
    @middle = Middle.new method_list
    @middle.bong
  end
end

class Middle
  attr_accessor :method_list, :bottom
  def initialize method_list
    @method_list = method_list
  end
  def bong
    @bottom = Bottom.new method_list
    @bottom.bang
  end
end

class Bottom
  attr_accessor :method_list
  def initialize method_list
    @method_list = method_list
  end
  def bang
    Pry.start(binding)
  end
end


describe "Commands" do
  let(:bingbong){ BingBong.new }

  before do
    Pry.config.hooks.add_hook(:when_started, :save_caller_bindings, WhenStartedHook)
    Pry.config.hooks.add_hook(:after_session, :delete_frame_manager, AfterSessionHook)

    method_list = []
    @top = Top.new method_list
  end

  after do
    Pry.config.hooks.delete_hook(:when_started, :save_caller_bindings)
    Pry.config.hooks.delete_hook(:after_session, :delete_frame_manager)
  end

  describe "up" do
    it 'should move up the call stack one frame at a time' do
      redirect_pry_io(InputTester.new("@methods << __method__",
                                      "up",
                                      "@methods << __method__",
                                      "up",
                                      "@methods << __method__",
                                      "exit-all"), out=StringIO.new) do
        bingbong.bing
      end

      expect(bingbong.methods).to eq [:bang, :bong, :bing]
    end

    it 'should move up the call stack two frames at a time' do
      redirect_pry_io(InputTester.new("@methods << __method__",
                                      "up 2",
                                      "@methods << __method__",
                                      "exit-all"), out=StringIO.new) do
        bingbong.bing
      end

      expect(bingbong.methods).to eq [:bang, :bing]
    end

    describe "by method name regex" do
      it 'should move to the method name that matches the regex' do
        redirect_pry_io(InputTester.new("@methods << __method__",
                                        "up bi",
                                        "@methods << __method__",
                                        "exit-all"), out=StringIO.new) do
          bingbong.bing
        end

        expect(bingbong.methods).to eq [:bang, :bing]
      end

      it 'should move through all methods that match regex in order' do
        redirect_pry_io(InputTester.new("@methods << __method__",
                                        "up b",
                                        "@methods << __method__",
                                        "up b",
                                        "@methods << __method__",
                                        "exit-all"), out=StringIO.new) do
          bingbong.bing
        end

        expect(bingbong.methods).to eq [:bang, :bong, :bing]
      end

      it 'should error if it cant find frame to match regex' do
        redirect_pry_io(InputTester.new("up conrad_irwin",
                                        "exit-all"), out=StringIO.new) do
          bingbong.bing
        end

        expect(out.string).to match(/Error: No frame that matches/)
      end
    end


    describe 'by Class#method name regex' do
      it 'should move to the method and class that matches the regex' do
        redirect_pry_io(InputTester.new("@method_list << self.class.to_s + '#' + __method__.to_s",
                                        'up Middle#bong',
                                        "@method_list << self.class.to_s + '#' + __method__.to_s",
                                        "exit-all"), out=StringIO.new) do
          @top.bing
        end

        expect(@top.method_list).to eq(['Bottom#bang', 'Middle#bong'])
      end

      ### ????? ###
      # it 'should be case sensitive' do
      # end
      ### ????? ###

      it 'should allow partial class names' do
          redirect_pry_io(InputTester.new("@method_list << self.class.to_s + '#' + __method__.to_s",
                                        'up Mid#bong',
                                        "@method_list << self.class.to_s + '#' + __method__.to_s",
                                        "exit-all"), out=StringIO.new) do
          @top.bing
        end

        expect(@top.method_list).to eq(['Bottom#bang', 'Middle#bong'])
      end

      it 'should allow partial method names' do
          redirect_pry_io(InputTester.new("@method_list << self.class.to_s + '#' + __method__.to_s",
                                        'up Middle#bo',
                                        "@method_list << self.class.to_s + '#' + __method__.to_s",
                                        "exit-all"), out=StringIO.new) do
          @top.bing
        end

        expect(@top.method_list).to eq(['Bottom#bang', 'Middle#bong'])
      end

      it 'should error if it cant find frame to match regex' do
        redirect_pry_io(InputTester.new('up Conrad#irwin',
                                        "exit-all"), out=StringIO.new) do
          @top.bing
        end

        expect(out.string).to match(/Error: No frame that matches/)
      end
    end
  end

  describe "down" do
    it 'should move down the call stack one frame at a time' do
      def bingbong.bang() Pry.start(binding, :initial_frame => 1) end

      redirect_pry_io(InputTester.new("@methods << __method__",
                                      "down",
                                      "@methods << __method__",
                                      "exit-all"), out=StringIO.new) do
        bingbong.bing
      end

      expect(bingbong.methods).to eq [:bong, :bang]
    end

    it 'should move down the call stack two frames at a time' do
      def bingbong.bang() Pry.start(binding, :initial_frame => 2) end

      redirect_pry_io(InputTester.new("@methods << __method__",
                                      "down 2",
                                      "@methods << __method__",
                                      "exit-all"), out=StringIO.new) do
        bingbong.bing
      end

      expect(bingbong.methods).to eq [:bing, :bang]
    end

    describe "by method name regex" do
      it 'should move to the method name that matches the regex' do
        redirect_pry_io(InputTester.new("frame -1",
                                        "down bo",
                                        "@methods << __method__",
                                        "exit-all"), out=StringIO.new) do
          bingbong.bing
        end

        expect(bingbong.methods[0]).to eq(:bong)
      end

      it 'should move through all methods that match regex in order' do
        redirect_pry_io(InputTester.new("frame bing",
                                        "@methods << __method__",
                                        "down b",
                                        "@methods << __method__",
                                        "down b",
                                        "@methods << __method__",
                                        "exit-all"), out=StringIO.new) do
          bingbong.bing
        end

        expect(bingbong.methods).to eq [:bing, :bong, :bang]
      end

      it 'should error if it cant find frame to match regex' do
        redirect_pry_io(InputTester.new("frame -1",
                                        "down conrad_irwin",
                                        "exit-all"), out=StringIO.new) do
          bingbong.bing
        end

        expect(out.string).to match(/Error: No frame that matches/)
      end
    end

    describe 'by Class#method name regex' do
      it 'should move to the method and class that matches the regex' do
        redirect_pry_io(InputTester.new('frame Top#bing',
                                        "@method_list << self.class.to_s + '#' + __method__.to_s",
                                        'down Middle#bong',
                                        "@method_list << self.class.to_s + '#' + __method__.to_s",
                                        "exit-all"), out=StringIO.new) do
          @top.bing
        end

        expect(@top.method_list).to eq(['Top#bing', 'Middle#bong'])
      end

      ### ????? ###
      # it 'should be case sensitive' do
      # end
      ### ????? ###

      it 'should error if it cant find frame to match regex' do
        redirect_pry_io(InputTester.new('down Conrad#irwin',
                                        "exit-all"), out=StringIO.new) do
          @top.bing
        end

        expect(out.string).to match(/Error: No frame that matches/)
      end
    end

  end

  describe "frame" do
    describe "by method name regex" do
      it 'should jump to correct stack frame when given method name' do
        redirect_pry_io(InputTester.new("frame bi",
                                        "@methods << __method__",
                                        "exit-all"), out=StringIO.new) do
          bingbong.bing
        end

        expect(bingbong.methods[0]).to eq(:bing)
      end

      it 'should NOT jump to frames lower down stack when given method name' do
        redirect_pry_io(InputTester.new("frame -1",
                                        "frame bang",
                                        "exit-all"), out=StringIO.new) do
          bingbong.bing
        end

        expect(out.string).to match(/Error: No frame that matches/)
      end

    end

    it 'should move to the given frame in the call stack' do
      redirect_pry_io(InputTester.new("frame 2",
                                      "@methods << __method__",
                                      "exit-all"), out=StringIO.new) do
        bingbong.bing
      end

      expect(bingbong.methods[0]).to eq(:bing)
    end

    it 'should return info on current frame when given no parameters' do
      redirect_pry_io(InputTester.new("frame",
                                      "exit-all"), out=StringIO.new) do
        bingbong.bing
      end

      expect(out.string).to match(/\#0.*?bang/)
      expect(out.string).not_to match(/\#1/)
    end

    describe "negative indices" do
      class AlphaBetaGamma
        attr_accessor :frame, :frame_number

        def alpha; binding; end
        def beta; binding; end
        def gamma; binding; end
      end

      let(:alphabetagamma){ AlphaBetaGamma.new }

      it 'should work with negative frame numbers' do
        o = AlphaBetaGamma.new

        call_stack   = [o.alpha, o.beta, o.gamma]
        method_names = call_stack.map { |v| v.eval('__method__') }.reverse
        (1..3).each_with_index do |v, idx|
          redirect_pry_io(InputTester.new("frame -#{v}",
                                          "@frame = __method__",
                                          "exit-all"), out=StringIO.new) do
            Pry.start(o, :call_stack => call_stack)
          end
          expect(o.frame).to eq(method_names[idx])
        end
      end

      it 'should convert negative indices to their positive counterparts' do
        o = AlphaBetaGamma.new

        call_stack = [o.alpha, o.beta, o.gamma]

        (1..3).each_with_index do |v, idx|
          issue_pry_commands(
            "frame -#{v}",
            "@frame_number = PryStackExplorer.frame_manager(pry_instance).binding_index",
            "exit-all"
          ){ Pry.start(o, call_stack: call_stack) }

          expect(o.frame_number).to eq(call_stack.size - v)
        end
      end
    end
  end
end
