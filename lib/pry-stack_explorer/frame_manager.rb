module PryStackExplorer

  class FrameManager
    include Enumerable

    attr_accessor :binding_index
    attr_accessor :bindings

    # @return [Hash] A hash for user defined data
    attr_reader :user

    # @return [Binding] The binding of the Pry instance before the
    #   FrameManager took over.
    attr_reader :prior_binding

    def initialize(bindings, _pry_)
      self.bindings      = bindings
      self.binding_index = 0
      @pry               = _pry_
      @user              = {}
      @prior_binding     = _pry_.binding_stack.last
    end

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
    def refresh_frame(run_whereami=true)
      change_frame_to binding_index, run_whereami
    end

    # @return [Binding] The currently active frame
    def current_frame
      bindings[binding_index]
    end

    # Set the binding index (aka frame index), but raising an Exception when invalid
    # index received. Also converts negative indices to their positive counterparts.
    # @param [Fixnum] index The index.
    def set_binding_index_safely(index)
      if index > bindings.size - 1
        raise Pry::CommandError, "At top of stack, cannot go further!"
      elsif index < -bindings.size
        raise Pry::CommandError, "At bottom of stack, cannot go further!"
      else
        # wrap around negative indices
        index = (bindings.size - 1) + index + 1 if index < 0

        self.binding_index = index
      end
    end

    # Change active frame to the one indexed by `index`.
    # Note that indexing base is `0`
    # @param [Fixnum] index The index of the frame.
    def change_frame_to(index, run_whereami=true)

      set_binding_index_safely(index)

      if @pry.binding_stack.empty?
        @pry.binding_stack.replace [bindings[binding_index]]
      else
        @pry.binding_stack[-1] = bindings[binding_index]
      end

      @pry.run_command "whereami" if run_whereami
    end

  end
end
