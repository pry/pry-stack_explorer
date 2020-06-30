module PryStackExplorer

  Commands = Pry::CommandSet.new do
    create_command "up", "Go up to the caller's context." do
      include FrameHelpers

      banner <<-BANNER
        Usage: up [OPTIONS]
          Go up to the caller's context. Accepts optional numeric parameter for how many frames to move up.
          Also accepts a string (regex) instead of numeric; for jumping to nearest parent method frame which matches the regex.
          e.g: up      #=> Move up 1 stack frame.
          e.g: up 3    #=> Move up 2 stack frames.
          e.g: up meth #=> Jump to nearest parent stack frame whose method matches /meth/ regex, i.e `my_method`.
      BANNER

      def process
        inc = args.first.nil? ? "1" : args.first

        if !frame_manager
          raise Pry::CommandError, "Nowhere to go!"
        else
          go_updown(:up, inc)
        end
      end
    end

    create_command "down", "Go down to the callee's context." do
      include FrameHelpers

      banner <<-BANNER
        Usage: down [OPTIONS]
          Go down to the callee's context. Accepts optional numeric parameter for how many frames to move down.
          Also accepts a string (regex) instead of numeric; for jumping to nearest child method frame which matches the regex.
          e.g: down      #=> Move down 1 stack frame.
          e.g: down 3    #=> Move down 2 stack frames.
          e.g: down meth #=> Jump to nearest child stack frame whose method matches /meth/ regex, i.e `my_method`.
      BANNER

      def process
        inc = args.first.nil? ? "1" : args.first

        if !frame_manager
          raise Pry::CommandError, "Nowhere to go!"
        else
          go_updown(:down, inc)
        end
      end
    end

    create_command "frame", "Switch to a particular frame." do
      include FrameHelpers

      banner <<-BANNER
        Usage: frame [OPTIONS]
          Switch to a particular frame. Accepts numeric parameter (or regex for method name) for the target frame to switch to (use with show-stack).
          Negative frame numbers allowed. When given no parameter show information about the current frame.

          e.g: frame 4         #=> jump to the 4th frame
          e.g: frame meth      #=> jump to nearest parent stack frame whose method matches /meth/ regex, i.e `my_method`
          e.g: frame -2        #=> jump to the second-to-last frame
          e.g: frame           #=> show information info about current frame
      BANNER

      def process
        raise Pry::CommandError, "Nowhere to go!" unless frame_manager

        if args[0].empty?
          frame = PryStackExplorer::Frame.make(target)
          output.puts "##{frame_manager.binding_index} #{frame.info(verbose: true)}"
        else
          go_updown(:up, args[0])
        end
      end
    end

    create_command "stack", "Show all frames" do
      include FrameHelpers

      banner <<-BANNER
        Usage: stack [OPTIONS]
          Show all accessible stack frames.
          e.g: stack -v

          alias: show-stack
      BANNER

      def options(opt)
        opt.on :v, :verbose, "Include extra information."
        opt.on :H, :head, "Display the first N stack frames (defaults to 10).", :optional_argument => true, :as => Integer, :default => 10
        opt.on :T, :tail, "Display the last N stack frames (defaults to 10).", :optional_argument => true, :as => Integer, :default => 10
        opt.on :c, :current, "Display N frames either side of current frame (default to 5).", :optional_argument => true, :as => Integer, :default => 5
        opt.on :a, :app, "Display application frames only", optional_argument: true
      end

      # @return [Array<Fixnum, Array<Binding>>] Return tuple of
      #   base_frame_index and the array of frames.
      def selected_stack_frames
        if opts.present?(:head)
          [0, frame_manager.bindings[0..(opts[:head] - 1)]]

        elsif opts.present?(:tail)
          tail = opts[:tail]
          if tail > frame_manager.bindings.size
            tail = frame_manager.bindings.size
          end

          base_frame_index = frame_manager.bindings.size - tail
          [base_frame_index, frame_manager.bindings[base_frame_index..-1]]

        elsif opts.present?(:current)
          first_frame_index = frame_manager.binding_index - (opts[:current])
          first_frame_index = 0 if first_frame_index < 0
          last_frame_index = frame_manager.binding_index + (opts[:current])
          [first_frame_index, frame_manager.bindings[first_frame_index..last_frame_index]]

        else
          [0, frame_manager.bindings]
        end
      end

      private :selected_stack_frames

      def process
        return no_stack_available! unless frame_manager

        title = "Showing all accessible frames in stack (#{frame_manager.bindings.size} in total):"

        content = [
          bold(title),
          "---",
          make_stack_lines
        ].join("\n")

        stagger_output content
      end

      private

      def make_stack_lines
        frames_with_indices.map do |b, i|
          make_stack_line(b, i, (i == frame_manager.binding_index))
        end.join("\n")
      end

      def frames_with_indices
        if opts.present?(:app) && defined?(ActiveSupport::BacktraceCleaner)
          app_frames
        else
          offset_frames
        end
      end

      ARROW = "=>"
      EMPTY = "  "

      # "=> #0  method_name <Class#method(...)>"
      def make_stack_line(b, i, active)
        arrow = active ? ARROW : EMPTY
        frame_no = i.to_s.rjust(2)
        frame_info = memoized_frame(i, b).info(verbose: opts[:v])

        [
          arrow,
          blue(bold frame_no) + ":",
          frame_info,
        ].join(" ")
      end

      def memoized_frame(index, b)
        frame_manager.user[:frame_info] ||= {}
        frame_manager.user[:frame_info][index] ||= PryStackExplorer::Frame.make(b)
      end

      def offset_frames
        base_frame_index, frames = selected_stack_frames

        frames.each_with_index.map do |frame, index|
          [frame, index + base_frame_index]
        end
      end

      def no_stack_available!
        output.puts "No caller stack available!"
      end

      LOCATION_LAMBDA = ->(_binding){ _binding.source_location[0] }

      def app_frames
        locations = frame_manager.bindings.map(&LOCATION_LAMBDA)
        filtered = backtrace_cleaner.clean(locations)

        frame_manager.bindings
          .each_with_index
          .map
          .select do |_binding, _index|
            LOCATION_LAMBDA.call(_binding).in?(filtered)
          end
      end

      # also see Rails::BacktraceCleaner
      def backtrace_cleaner
        @backtrace_cleaner ||= ActiveSupport::BacktraceCleaner.new
      end
    end

    alias_command "show-stack", "stack"

  end
end
