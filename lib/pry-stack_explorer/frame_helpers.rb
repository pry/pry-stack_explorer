module PryStackExplorer
  module FrameHelpers
    private

    # @return [PryStackExplorer::FrameManager] The active frame manager for
    #   the current `Pry` instance.
    def frame_manager
      PryStackExplorer.frame_manager(pry_instance)
    end

    # @return [Array<PryStackExplorer::FrameManager>] All the frame
    #   managers for the current `Pry` instance.
    def frame_managers
      PryStackExplorer.frame_managers(pry_instance)
    end

    # @return [Boolean] Whether there is a context to return to once
    #   the current `frame_manager` is popped.
    def prior_context_exists?
      frame_managers.count > 1 || frame_manager.prior_binding
    end


    #  Regexp.new(args[0])
    def find_frame_by_regex(regex, up_or_down)
      frame_index = frame_manager.find_frame_by_block(up_or_down) do |b|
        b.eval("__method__").to_s =~ regex
      end

      if frame_index
        frame_index
      else
        raise Pry::CommandError, "No frame that matches #{regex.source} found!"
      end
    end

    def find_frame_by_object_regex(class_regex, method_regex, up_or_down)
      frame_index = frame_manager.find_frame_by_block(up_or_down) do |b|
        class_match = b.eval("self.class").to_s =~ class_regex
        meth_match = b.eval("__method__").to_s =~ method_regex

        class_match && meth_match
      end

      if frame_index
        frame_index
      else
        raise Pry::CommandError, "No frame that matches #{class_regex.source}" + '#' + "#{method_regex.source} found!"
      end
    end
  end
end
