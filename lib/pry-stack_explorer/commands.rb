module PryStackExplorer
  StackCommands = Pry::CommandSet.new do
    command "up", "Go up to the caller's context" do |inc_str|
      inc = inc_str.nil? ? 1 : inc_str.to_i

      if !PryStackExplorer.frame_manager(_pry_)
        output.puts "Nowhere to go!"
      else
        binding_index = PryStackExplorer.frame_manager(_pry_).binding_index
        PryStackExplorer.frame_manager(_pry_).change_frame_to binding_index + inc 
      end
    end

    command "down", "Go down to the callee's context." do |inc_str|
      inc = inc_str.nil? ? 1 : inc_str.to_i

      if !PryStackExplorer.frame_manager(_pry_) 
        output.puts "Nowhere to go!"
      else
        binding_index = PryStackExplorer.frame_manager(_pry_).binding_index
        PryStackExplorer.frame_manager(_pry_).change_frame_to binding_index - inc 
      end
    end

    command "show-stack", "Show all frames" do |*args|
      opts = parse_options!(args) do |opt|
        opt.banner unindent <<-USAGE
            Usage: show-stack [OPTIONS]
            Show all accessible stack frames.
            e.g: show-stack -v
          USAGE

        opt.on :v, :verbose, "Include extra information."
      end

      if !PryStackExplorer.frame_manager(_pry_)
        output.puts "No caller stack available!"
      else
        output.puts "\n#{text.bold('Showing all accessible frames in stack:')}\n--\n"

        PryStackExplorer.frame_manager(_pry_).each_with_index do |b, i|
          meth = b.eval('__method__')
          b_self = b.eval('self')

          desc = b.frame_description ? "#{text.bold('Description:')} #{b.frame_description}".ljust(40) :
            "#{text.bold('Description:')} #{PryStackExplorer.frame_manager(_pry_).frame_info_for(b)}".ljust(40)
          sig = meth ? "#{text.bold('Signature:')} #{Pry::Method.new(b_self.method(meth)).signature}".ljust(40) : "".ljust(32)
          type = b.frame_type ? "#{text.bold('Type:')} #{b.frame_type}".ljust(20) : "".ljust(20)
          slf_class = "#{text.bold('Self.class:')} #{b_self.class}".ljust(20)
          path = "#{text.bold("@ File:")} #{b.eval('__FILE__')}:#{b.eval('__LINE__')}"

          info = "##{i} #{desc} #{slf_class} #{sig} #{type \
                  if opts[:v]} #{path if opts[:v]}"
          if i == PryStackExplorer.frame_manager(_pry_).binding_index
            output.puts "=> #{info}"
          else
            output.puts "   #{info}"
          end
        end
      end
    end

    command "frame", "Switch to a particular frame." do |frame_num|
      if !PryStackExplorer.frame_manager(_pry_)
        output.puts "nowhere to go!"
      else
        PryStackExplorer.frame_manager(_pry_).change_frame_to frame_num.to_i
      end
    end

    command "frame-type", "Display current frame type." do
      output.puts _pry_.binding_stack.last.frame_type
    end
  end
end
