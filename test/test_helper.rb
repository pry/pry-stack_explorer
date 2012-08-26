require 'ostruct'
require 'pry'

require_relative 'support/input_tester'
require_relative 'support/bingbong'

# unless Object.const_defined? 'PryStackExplorer'
  $:.unshift File.expand_path '../../lib', __FILE__
  require 'pry-stack_explorer'
# end

puts "Testing pry-stack_explorer version #{PryStackExplorer::VERSION}..."
puts "Ruby version: #{RUBY_VERSION}"

PE = PryStackExplorer

class << Pry
  alias_method :orig_reset_defaults, :reset_defaults

  def reset_defaults
    orig_reset_defaults

    Pry.color = false
    Pry.pager = false
    Pry.config.should_load_rc      = false
    Pry.config.should_load_plugins = false
    Pry.config.auto_indent         = false
    Pry.config.hooks               = Pry::Hooks.new
    Pry.config.collision_warning   = false
  end
end

AfterSessionHook = Pry.config.hooks.get_hook(:after_session, :delete_frame_manager)
WhenStartedHook  = Pry.config.hooks.get_hook(:when_started, :save_caller_bindings)

Pry.reset_defaults

module PryTestUtils

  # Set I/O streams.
  #
  # Out defaults to an anonymous StringIO.
  def with_pry_output_captured(new_in, new_out = StringIO.new)
    old_in = Pry.input
    old_out = Pry.output

    Pry.input = new_in
    Pry.output = new_out


    begin
      yield
    ensure
      Pry.input = old_in
      Pry.output = old_out
    end

    new_out
  end

  alias :redirect_pry_io :with_pry_output_captured


  def mock_pry(*args)
    binding = args.first.is_a?(Binding) ? args.shift : binding()

    input = InputTester.new(*args)
    output = StringIO.new

    redirect_pry_io(input, output) do
      binding.pry
    end

    output.string
  end

  def issue_pry_commands(*commands, &block)
    input_tester = InputTester.new(*commands)
    redirect_pry_io(input_tester, &block).string
  end
end

include PryTestUtils