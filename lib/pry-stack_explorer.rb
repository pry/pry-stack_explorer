# pry-stack_explorer.rb
# (C) John Mair (banisterfiend); MIT license

require "pry-stack_explorer/version"
require "pry"
require "binding_of_caller"

module PryStackExplorer

  def self.frame_manager
    Thread.current[:__pry_frame_manager__]
  end

  def self.frame_manager=(obj)
    Thread.current[:__pry_frame_manager__] = obj
  end

  def self.bindings_equal?(b1, b2)
    (b1.eval('self') == b2.eval('self')) &&
      (b1.eval('__method__') == b2.eval('__method__')) &&
      (b1.eval('local_variables').map { |v| b1.eval("#{v}") } ==
       b2.eval('local_variables').map { |v| b2.eval("#{v}") })
  end

  class FrameManager
    attr_reader   :binding_index
    attr_accessor :bindings

    def initialize(bindings)
      @bindings      = bindings
      @binding_index = 0
    end

    def convert_from_one_index(n)
      if n >= 0
        n - 1
      else
        n
      end
    end

    def change_binding_to(index, pry_instance)
      index = convert_from_one_index(index)

      if index > bindings.size - 1
        pry_instance.output.puts "Warning: At top of stack, cannot go further!"
      elsif index < 0
        pry_instance.output.puts "Warning: At bottom of stack, cannot go further!"
      else
        @binding_index = index
        pry_instance.binding_stack[-1] = bindings[binding_index]

        pry_instance.run_command "whereami"
      end
    end
  end

  StackCommands = Pry::CommandSet.new do
    command "up", "Go up to the caller's context" do |inc_str|
      inc = inc_str.nil? ? 1 : inc_str.to_i

      if !PryStackExplorer.frame_manager
        output.puts "Nowhere to go!"
      else
        binding_index = PryStackExplorer.frame_manager.binding_index
        PryStackExplorer.frame_manager.change_binding_to binding_index + inc + 1, _pry_
      end
    end

    command "down", "Go down to the callee's context." do |inc_str|
      inc = inc_str.nil? ? 1 : inc_str.to_i

      if !PryStackExplorer.frame_manager
        output.puts "Nowhere to go!"
      else
        binding_index = PryStackExplorer.frame_manager.binding_index
        PryStackExplorer.frame_manager.change_binding_to binding_index - inc + 1, _pry_
      end
    end

    command "frame", "Switch to a particular frame." do |frame_num|
      PryStackExplorer.frame_manager.change_binding_to frame_num.to_i, _pry_
    end

    command "frame-type", "Display current frame type." do
      bindex = PryStackExplorer.frame_manager.binding_index
      output.puts PryStackExplorer.frame_manager.bindings[bindex].frame_type
    end
  end
end

Pry.config.hooks.add_hook(:when_started) do |target|
  if binding.of_caller(4).eval('__method__') == :pry
    drop_number = 5
  else
    drop_number = 4
  end

  bindings = binding.callers.drop(drop_number)

  # Use the binding returned by #of_caller if possible (as we get
  # access to frame_type).
  # Otherwise stick to the given binding (target).
  if !PryStackExplorer.bindings_equal?(target, bindings.first)
    bindings.shift
    bindings.unshift(target)
  end

  PryStackExplorer.frame_manager = PryStackExplorer::FrameManager.new(bindings)
end

Pry.config.commands.import PryStackExplorer::StackCommands

Pry.config.commands.alias_command "__old_whereami__", "whereami", ""

# monkey-patch the whereami command to show some frame information,
# useful for navigating stack.
Pry.config.commands.command "whereami", "Show the code context for the session. (whereami <n> shows <n> extra lines of code around the invocation line. Default: 5)" do |num|
  if PryStackExplorer.frame_manager
    bindings      = PryStackExplorer.frame_manager.bindings
    binding_index = PryStackExplorer.frame_manager.binding_index

    output.puts "\n"
    output.puts "#{Pry::Helpers::Text.bold('Frame number:')} #{binding_index + 1}/#{bindings.size}"
    output.puts "#{Pry::Helpers::Text.bold('Frame type:')} #{bindings[binding_index].frame_type}" rescue nil
  end

  run "__old_whereami__", num
end
