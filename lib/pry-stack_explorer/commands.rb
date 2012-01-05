require 'pry'

module PryStackExplorer
  StackCommands = Pry::CommandSet.new do
    command "up", "Go up to the caller's context. Accepts optional numeric parameter for how many frames to move up." do |inc_str|
      inc = inc_str.nil? ? 1 : inc_str.to_i

      if !PryStackExplorer.frame_manager(_pry_)
        output.puts "Nowhere to go!"
      else
        binding_index = PryStackExplorer.frame_manager(_pry_).binding_index
        PryStackExplorer.frame_manager(_pry_).change_frame_to binding_index + inc
      end
    end

    command "down", "Go down to the callee's context. Accepts optional numeric parameter for how many frames to move down." do |inc_str|
      inc = inc_str.nil? ? 1 : inc_str.to_i

      if !PryStackExplorer.frame_manager(_pry_)
        output.puts "Nowhere to go!"
      else
        binding_index = PryStackExplorer.frame_manager(_pry_).binding_index
        if binding_index - inc < 0
          raise Pry::CommandError, "At bottom of stack, cannot go further!"
        else
          PryStackExplorer.frame_manager(_pry_).change_frame_to binding_index - inc
        end
      end
    end

    command_class "show-stack", "Show all frames" do
      def options(opt)
        opt.banner unindent <<-USAGE
            Usage: show-stack [OPTIONS]
            Show all accessible stack frames.
            e.g: show-stack -v
          USAGE

        opt.on :v, :verbose, "Include extra information."
      end

      def process
        if !PryStackExplorer.frame_manager(_pry_)
          output.puts "No caller stack available!"
        else
          content = ""
          content << "\n#{text.bold('Showing all accessible frames in stack:')}\n--\n"

          PryStackExplorer.frame_manager(_pry_).each_with_index do |b, i|
            if i == PryStackExplorer.frame_manager(_pry_).binding_index
              content << "=> ##{i} #{frame_info(b, opts[:v])}\n"
            else
              content << "   ##{i} #{frame_info(b, opts[:v])}\n"
            end
          end

          stagger_output content
        end
      end
    end

    command "frame", "Switch to a particular frame. Accepts numeric parameter for the target frame to switch to (use with show-stack). Negative frame numbers allowed." do |frame_num|
      if !PryStackExplorer.frame_manager(_pry_)
        output.puts "nowhere to go!"
      else
        if frame_num
          PryStackExplorer.frame_manager(_pry_).change_frame_to frame_num.to_i
        else
          output.puts "##{PryStackExplorer.frame_manager(_pry_).binding_index} #{frame_info(target, true)}"
        end
      end
    end

    helpers do
      def frame_info(b, verbose = false)
        meth = b.eval('__method__')
        b_self = b.eval('self')
        meth_obj = Pry::Method.from_binding(b) if meth

        type = b.frame_type ? "[#{b.frame_type}]".ljust(9) : ""
        desc = b.frame_description ? "#{b.frame_description}" : "#{PryStackExplorer.frame_manager(_pry_).frame_info_for(b)}"
        sig = meth_obj ? "<#{se_signature_with_owner(meth_obj)}>" : ""

        self_clipped = "#{Pry.view_clip(b_self)}"
        path = "@ #{b.eval('__FILE__')}:#{b.eval('__LINE__')}"

        if !verbose
          "#{type} #{desc} #{sig}"
        else
          "#{type} #{desc} #{sig}\n      in #{self_clipped} #{path}"
        end
      end

      def se_signature_with_owner(meth_obj)
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

  end
end
