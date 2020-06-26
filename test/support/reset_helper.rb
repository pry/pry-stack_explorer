module ResetHelper

  def self.reset_pry_defaults!
    # Pry.reset_defaults

    # Pry.color = false
    Pry.pager = false
    Pry.config.hooks               = Pry::Hooks.new
    # Pry.config.should_load_rc      = false
    # Pry.config.should_load_plugins = false
    # Pry.config.auto_indent         = false
    # Pry.config.collision_warning   = false
  end

  def hooks
    Hooks
  end

  def self.included(base)
    base.class_exec do
      before :all do
        ResetHelper.reset_pry_defaults!
      end

      around do |example|
        hooks.with_setup{ example.run }
      end
    end
  end

  module Hooks; end

  class << Hooks
    def memoize!
      @@hooks = {
        when_started: Pry.config.hooks.get_hook(:when_started, :save_caller_bindings),
        after_session: Pry.config.hooks.get_hook(:after_session, :delete_frame_manager)
      }
    end

    def setup!
      Pry.config.hooks.add_hook(:when_started, :save_caller_bindings, @@hooks[:when_started])
      Pry.config.hooks.add_hook(:after_session, :delete_frame_manager, @@hooks[:after_session])
    end

    def teardown!
      Pry.config.hooks.delete_hook(:when_started, :save_caller_bindings)
      Pry.config.hooks.delete_hook(:after_session, :delete_frame_manager)
    end

    def with_setup(&block)
      setup!
      yield
      teardown!
    end
  end
end
