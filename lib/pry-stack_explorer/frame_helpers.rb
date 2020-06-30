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

    def go_updown(up_or_down, argument)
      if argument =~ /\d+/
        frame_manager.travel(argument.to_i, up_or_down)
      elsif match = /^([A-Z]+[^#.]*)(#|\.)(.+)$/.match(argument)
        frame_manager.change_frame_by_object_regex(Regexp.new(match[1]), Regexp.new(match[3]), up_or_down)
      elsif argument =~ /^[^-].*$/
        frame_manager.change_frame_by_regex(Regexp.new(argument), up_or_down)
      end
    end
  end
end
