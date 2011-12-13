module PryStackExplorer
  
  class FrameManager
    include Enumerable
    
    attr_accessor :binding_index
    attr_accessor :bindings

    def initialize(bindings, _pry_)
      self.bindings      = bindings
      self.binding_index = 0
      @pry               = _pry_
    end

    # Replace the current set of bindings (call stack) and binding
    # index (current frame)
    # @param [Array] bindings The new call stack (array of bindings)
    # @param [Fixnum] binding_index The currently 'active' frame (binding).
    def replace_call_stack(bindings, binding_index = 0)
      self.bindings      = bindings
      self.binding_index = binding_index
    end

    def convert_from_one_index(n)
      if n >= 0
        n - 1
      else
        n
      end
    end
    private :convert_from_one_index

    # Iterate over all frames
    def each(&block)
      bindings.each(&block)
    end

    # Return a description of the frame (binding)
    # @param [Binding] b The binding.
    # @return [String] A description of the frame (binding).
    def frame_info_for(b)
      b_self = b.eval('self')
      b_method = b.eval('__method__')

      if b_method && b_method != :__binding__ && b_method != :__binding_impl__
        b_method.to_s
      elsif b_self.instance_of?(Module)
        "<module:#{b_self}>"
      elsif b_self.instance_of?(Class)
        "<class:#{b_self}>"
      else
        "<main>"
      end
    end

    # Ensure the Pry instance's active binding is the frame manager's
    # active binding.
    def refresh_frame
      change_frame_to binding_index + 1
    end

    # Change active frame to the one indexed by `index`.
    # Note that indexing base is `1`
    # @param [Fixnum] index The index of the frame.
    def change_frame_to(index)
      index = convert_from_one_index(index)

      if index > bindings.size - 1
        @pry.output.puts "Warning: At top of stack, cannot go further!"
      elsif index < 0
        @pry.output.puts "Warning: At bottom of stack, cannot go further!"
      else
        self.binding_index = index
        @pry.binding_stack[-1] = bindings[binding_index]

        @pry.run_command "whereami"
      end
    end
    
  end
end
