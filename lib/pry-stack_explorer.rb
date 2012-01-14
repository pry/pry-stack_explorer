# pry-stack_explorer.rb
# (C) John Mair (banisterfiend); MIT license

require "pry-stack_explorer/version"
require "pry-stack_explorer/commands"
require "pry-stack_explorer/frame_manager"
require "pry-stack_explorer/when_started_hook"
require "pry"
require "binding_of_caller"

module PryStackExplorer

  # @return [Hash] The hash storing all frames for all Pry instances for
  #   the current thread
  def self.frame_hash
    Thread.current[:__pry_frame_managers__]
  end

  def self.init_frame_hash
    Thread.current[:__pry_frame_managers__] ||= Hash.new { |h, k| h[k] = [] }
  end

  # Create a `Pry::FrameManager` object and push it onto the frame
  # manager stack for the relevant `_pry_` instance.
  # @param [Array] bindings The array of bindings (frames)
  # @param [Pry] _pry_ The Pry instance associated with the frame manager
  def self.create_and_push_frame_manager(bindings, _pry_)
    init_frame_hash
    frame_hash[_pry_].push FrameManager.new(bindings, _pry_)
  end

  # Return the complete frame manager stack for the Pry instance
  # @param [Pry] _pry_ The Pry instance associated with the frame
  #   managers
  # @return [Array] The stack of Pry::FrameManager objections
  def self.frame_managers(_pry_)
    init_frame_hash
    frame_hash[_pry_]
  end

  # Delete the currently active frame manager
  # @param [Pry] _pry_ The Pry instance associated with the frame managers
  def self.pop_frame_manager(_pry_)
    init_frame_hash
    popped = frame_managers(_pry_).pop
    frame_hash.delete(_pry_) if frame_managers(_pry_).empty?
    _pry_.backtrace = popped.prior_backtrace
    popped
  end

  # Clear the stack of frame managers for the Pry instance
  # @param [Pry] _pry_ The Pry instance associated with the frame managers
  def self.clear_frame_managers(_pry_)
    init_frame_hash
    pop_frame_manager(_pry_) until frame_managers(_pry_).empty?
    frame_hash.delete(_pry_) # this line should be unnecessary!
  end

  class << self; alias_method :delete_frame_managers, :clear_frame_managers; end

  # @return [PryStackExplorer::FrameManager] The currently active frame manager
  def self.frame_manager(_pry_)
    init_frame_hash
    frame_hash[_pry_].last
  end

  # Simple test to check whether two `Binding` objects are equal.
  # @param [Binding] b1 First binding.
  # @param [Binding] b2 Second binding.
  def self.bindings_equal?(b1, b2)
    (b1.eval('self') == b2.eval('self')) &&
      (b1.eval('__method__') == b2.eval('__method__')) &&
      (b1.eval('local_variables').map { |v| b1.eval("#{v}") } ==
       b2.eval('local_variables').map { |v| b2.eval("#{v}") })
  end
end

Pry.config.hooks.add_hook(:after_session, :delete_frame_manager) do |_, _, _pry_|
  PryStackExplorer.clear_frame_managers(_pry_)
end

Pry.config.hooks.add_hook(:when_started, :save_caller_bindings, PryStackExplorer::WhenStartedHook.new)

# Import the StackExplorer commands
Pry.config.commands.import PryStackExplorer::Commands

# monkey-patch the whereami command to show some frame information,
# useful for navigating stack.
Pry.config.commands.before_command("whereami") do |num|
  if PryStackExplorer.frame_manager(_pry_)
    bindings      = PryStackExplorer.frame_manager(_pry_).bindings
    binding_index = PryStackExplorer.frame_manager(_pry_).binding_index

    output.puts "\n"
    output.puts "#{Pry::Helpers::Text.bold('Frame number:')} #{binding_index}/#{bindings.size - 1}"
    output.puts "#{Pry::Helpers::Text.bold('Frame type:')} #{bindings[binding_index].frame_type}" if bindings[binding_index].frame_type
  end
end
