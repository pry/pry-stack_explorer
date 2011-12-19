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
          if i == PryStackExplorer.frame_manager(_pry_).binding_index
            output.puts "=> ##{i} #{frame_info(b, opts[:v])}"
          else
            output.puts "   ##{i} #{frame_info(b, opts[:v])}"
          end
        end
      end
    end

    command "frame", "Switch to a particular frame." do |frame_num|
      if !PryStackExplorer.frame_manager(_pry_)
        output.puts "nowhere to go!"
      else
        if frame_num
          PryStackExplorer.frame_manager(_pry_).change_frame_to frame_num.to_i
        else
          output.puts "##{PryStackExplorer.frame_manager(_pry_).binding_index} #{frame_info(target)}"
        end
      end
    end

    command "frame-type", "Display current frame type." do
      output.puts _pry_.binding_stack.last.frame_type
    end

    helpers do
      def frame_info(b, verbose = false)
        meth = b.eval('__method__')
        methobj = b.eval('method(__method__)') if meth
        b_self = b.eval('self')

        desc = b.frame_description ? "#{text.bold('Description:')} #{b.frame_description}".ljust(40) :
          "#{text.bold('Description:')} #{PryStackExplorer.frame_manager(_pry_).frame_info_for(b)}".ljust(40)
        sig = meth ? "#{text.bold('Signature:')} #{signature_with_values(b, methobj)}".ljust(40) : "".ljust(32)
        type = b.frame_type ? "#{text.bold('Type:')} #{b.frame_type}".ljust(20) : "".ljust(20)
        slf_class = "#{text.bold('Self.class:')} #{b_self.class}".ljust(20)
        path = "#{text.bold("@ File:")} #{b.eval('__FILE__')}:#{b.eval('__LINE__')}"

        "#{desc} #{slf_class} #{sig} #{type if verbose} #{path if verbose}"
      end

      def signature_with_values(b, meth)
          args = meth.parameters.inject([]) do |arr, (type, name)|
            name ||= (type == :block ? 'block' : "arg#{arr.size + 1}")
            arr << case type
                   when :req   then "#{name}=#{b.eval(name.to_s)}"
                   when :opt   then "#{name}=#{b.eval(name.to_s)}"
                   when :rest  then "*#{name}=#{b.eval(name.to_s)}"
                   when :block then "&#{name}"
                   else '?'
                   end
        end
        "#{meth.name}(#{args.join(', ')})"
      end

    end

  end
end
