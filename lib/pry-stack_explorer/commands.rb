require 'pry'

module PryStackExplorer
  module FrameHelpers
    private
    def frame_manager
      PryStackExplorer.frame_manager(_pry_)
    end

    def frame_managers
      PryStackExplorer.frame_managers(_pry_)
    end

    def prior_context_exists?
      frame_managers.count > 1 || frame_manager.prior_binding
    end

    # Return a description of the frame (binding).
    # This is only useful for regular old bindings that have not been
    # enhanced by `#of_caller`.
    # @param [Binding] b The binding.
    # @return [String] A description of the frame (binding).
    def frame_description(b)
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

    # Return a description of the passed binding object. Accepts an
    # optional `verbose` parameter.
    # @param [Binding] b The binding.
    # @param [Boolean] verbose Whether to generate a verbose description.
    # @return [String] The description of the binding.
    def frame_info(b, verbose = false)
      meth = b.eval('__method__')
      b_self = b.eval('self')
      meth_obj = Pry::Method.from_binding(b) if meth

      type = b.frame_type ? "[#{b.frame_type}]".ljust(9) : ""
      desc = b.frame_description ? "#{b.frame_description}" : "#{frame_description(b)}"
      sig = meth_obj ? "<#{signature_with_owner(meth_obj)}>" : ""

      self_clipped = "#{Pry.view_clip(b_self)}"
      path = "@ #{b.eval('__FILE__')}:#{b.eval('__LINE__')}"

      if !verbose
        "#{type} #{desc} #{sig}"
      else
        "#{type} #{desc} #{sig}\n      in #{self_clipped} #{path}"
      end
    end

    def signature_with_owner(meth_obj)
      if !meth_obj.undefined?
        args = meth_obj.parameters.inject([]) do |arr, (type, name)|
          name ||= (type == :block ? 'block' : "arg#{arr.size + 1}")
          arr << case type
                 when :req   then name.to_s
                 when :opt   then "#{name}=?"
                 when :rest  then "*#{name}"
                 when :block then "&#{name}"
                 else '?'
                 end
        end
        "#{meth_obj.name_with_owner}(#{args.join(', ')})"
      else
        "#{meth_obj.name_with_owner}(UNKNOWN) (undefined method)"
      end
    end
  end

  Commands = Pry::CommandSet.new do
    create_command "up", "Go up to the caller's context. Accepts optional numeric parameter for how many frames to move up." do
      include FrameHelpers

      banner <<-BANNER
        Usage: up [OPTIONS]
          Go up to the caller's context. Accepts optional numeric parameter for how many frames to move up.
          e.g: up
          e.g: up 3
      BANNER

      def process
        inc = args.first.nil? ? 1 : args.first.to_i

        if !frame_manager
          raise Pry::CommandError, "Nowhere to go!"
        else
          frame_manager.change_frame_to frame_manager.binding_index + inc
        end
      end
    end

    create_command "down", "Go down to the callee's context. Accepts optional numeric parameter for how many frames to move down." do
      include FrameHelpers

      banner <<-BANNER
        Usage: down [OPTIONS]
          Go down to the callee's context. Accepts optional numeric parameter for how many frames to move down.
          e.g: down
          e.g: down 3
      BANNER

      def process
        inc = args.first.nil? ? 1 : args.first.to_i

        if !frame_manager
          raise Pry::CommandError, "Nowhere to go!"
        else
          if frame_manager.binding_index - inc < 0
            raise Pry::CommandError, "At bottom of stack, cannot go further!"
          else
            frame_manager.change_frame_to frame_manager.binding_index - inc
          end
        end
      end
    end

    create_command "show-stack", "Show all frames" do
      include FrameHelpers

      banner <<-BANNER
        Usage: show-stack [OPTIONS]
          Show all accessible stack frames.
          e.g: show-stack -v
      BANNER

      def options(opt)
        opt.on :v, :verbose, "Include extra information."
      end

      def process
        if !frame_manager
          output.puts "No caller stack available!"
        else
          content = ""
          content << "\n#{text.bold('Showing all accessible frames in stack:')}\n--\n"

          frame_manager.each_with_index do |b, i|
            if i == frame_manager.binding_index
              content << "=> ##{i} #{frame_info(b, opts[:v])}\n"
            else
              content << "   ##{i} #{frame_info(b, opts[:v])}\n"
            end
          end

          stagger_output content
        end
      end

    end

    # TODO: currently using `arg_string` as a work-around for a Slop
    # bug where `-2` (negative number) is interpreted as a
    # non-existent option rather than a non-option
    create_command "frame", "Switch to a particular frame. Accepts numeric parameter for the target frame to switch to (use with show-stack). Negative frame numbers allowed." do
      include FrameHelpers

      banner <<-BANNER
        Usage: frame [OPTIONS]
          Switch to a particular frame. Accepts numeric parameter for the target frame to switch to (use with show-stack). Negative frame numbers allowed.
          e.g: frame 4
          e.g: frame -2
      BANNER

      def process
        if !frame_manager
          raise Pry::CommandError, "nowhere to go!"
        else

          if args[0]
            frame_manager.change_frame_to args[0].to_i
          else
            output.puts "##{frame_manager.binding_index} #{frame_info(target, true)}"
          end
        end
      end
    end
  end
end
