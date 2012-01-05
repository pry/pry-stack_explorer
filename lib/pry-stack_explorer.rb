# pry-stack_explorer.rb
# (C) John Mair (banisterfiend); MIT license

require "pry-stack_explorer/version"
require "pry-stack_explorer/commands"
require "pry-stack_explorer/frame_manager"
require "pry"
require "binding_of_caller"

module PryStackExplorer

  def self.init_frame_hash
    Thread.current[:__pry_frame_managers__] ||= Hash.new { |h, k| h[k] = [] }
  end

  # Create a `Pry::FrameManager` object and push it onto the frame
  # manager stack for the relevant `_pry_` instance.
  # @param [Array] bindings The array of bindings (frames)
  # @param [Pry] _pry_ The Pry instance associated with the frame manager
  def self.create_and_push_frame_manager(bindings, _pry_)
    init_frame_hash
    Thread.current[:__pry_frame_managers__][_pry_].push FrameManager.new(bindings, _pry_)
  end

  # Return the complete frame manager stack for the Pry instance
  # @param [Pry] _pry_ The Pry instance associated with the frame
  #   managers
  # @return [Array] The stack of Pry::FrameManager objections
  def self.all_frame_managers(_pry_)
    init_frame_hash
    Thread.current[:__pry_frame_managers__][_pry_]
  end

  # Delete the currently active frame manager
  # @param [Pry] _pry_ The Pry instance associated with the frame managers
  def self.pop_frame_manager(_pry_)
    init_frame_hash
    Thread.current[:__pry_frame_managers__][_pry_].pop
  end

  # Clear the stack of frame managers for the Pry instance
  # @param [Pry] _pry_ The Pry instance associated with the frame managers
  def self.clear_frame_managers(_pry_)
    init_frame_hash
    Thread.current[:__pry_frame_managers__][_pry_].clear
  end

  # @return [PryStackExplorer::FrameManager] The currently active frame manager
  def self.frame_manager(_pry_)
    init_frame_hash
    Thread.current[:__pry_frame_managers__][_pry_].last
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

Pry.config.hooks.add_hook(:when_started, :save_caller_bindings) do |binding_stack, options, _pry_|
  options[:call_stack]    = true unless options.has_key?(:call_stack)
  options[:initial_frame] = 0 unless options.has_key?(:initial_frame)
  initial_frame = options[:initial_frame]

  next if !options[:call_stack]

  if options[:call_stack].is_a?(Array)
    bindings = options[:call_stack]
    raise ArgumentError, ":call_stack must be an array of bindings" if bindings.empty? || !bindings.all? { |v| v.is_a?(Binding) }
  else
    target = binding_stack.last

    if binding.of_caller(6).eval('__method__') == :pry
      drop_number = 7
    else
      drop_number = 6
    end

    bindings = binding.callers.drop(drop_number)

    # Use the binding returned by #of_caller if possible (as we get
    # access to frame_type).
    # Otherwise stick to the given binding (target).
    if !PryStackExplorer.bindings_equal?(target, bindings.first)
      bindings.shift
      bindings.unshift(target)
    end
  end

  binding_stack.replace [bindings[initial_frame]]
  PryStackExplorer.create_and_push_frame_manager(bindings, _pry_)
  PryStackExplorer.frame_manager(_pry_).set_binding_index_safely(initial_frame)
end

# Import the StackExplorer commands
Pry.config.commands.import PryStackExplorer::StackCommands

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
