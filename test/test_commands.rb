require 'helper'

describe PryStackExplorer::StackCommands do

  before do
    Pry.config.hooks.add_hook(:when_started, :save_caller_bindings, &WhenStartedHook)
    Pry.config.hooks.add_hook(:after_session, :delete_frame_manager, &AfterSessionHook)

    @o = Object.new
    class << @o; attr_accessor :first_method, :second_method, :third_method; end
    def @o.bing() bong end
    def @o.bong() bang end
    def @o.bang() Pry.start(binding) end
  end

  after do
    Pry.config.hooks.delete_hook(:when_started, :save_caller_bindings)
    Pry.config.hooks.delete_hook(:after_session, :delete_frame_manager)
  end

  describe "up" do
    it 'should move up the call stack one frame at a time' do
      redirect_pry_io(InputTester.new("@first_method = __method__",
                                      "up",
                                      "@second_method = __method__",
                                      "up",
                                      "@third_method = __method__",
                                      "exit-all"), out=StringIO.new) do
        @o.bing
      end

      @o.first_method.should  == :bang
      @o.second_method.should == :bong
      @o.third_method.should  == :bing
    end

    it 'should move up the call stack two frames at a time' do
      redirect_pry_io(InputTester.new("@first_method = __method__",
                                      "up 2",
                                      "@second_method = __method__",
                                      "exit-all"), out=StringIO.new) do
        @o.bing
      end

      @o.first_method.should  == :bang
      @o.second_method.should == :bing
    end
  end

  describe "down" do
    it 'should move down the call stack one frame at a time' do
      def @o.bang() Pry.start(binding, :initial_frame => 1) end

      redirect_pry_io(InputTester.new("@first_method = __method__",
                                      "down",
                                      "@second_method = __method__",
                                      "exit-all"), out=StringIO.new) do
        @o.bing
      end

      @o.first_method.should  == :bong
      @o.second_method.should == :bang
    end

    it 'should move down the call stack two frames at a time' do
      def @o.bang() Pry.start(binding, :initial_frame => 2) end

      redirect_pry_io(InputTester.new("@first_method = __method__",
                                      "down 2",
                                      "@second_method = __method__",
                                      "exit-all"), out=StringIO.new) do
        @o.bing
      end

      @o.first_method.should  == :bing
      @o.second_method.should == :bang
    end
  end

end
