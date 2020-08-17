require_relative "frame/it_block"

module PryStackExplorer
  class Frame
    attr_reader :b

    def self.make(_binding)
      if defined?(RSpec::Core) && _binding.receiver.is_a?(RSpec::Core::ExampleGroup)
        ItBlock.new(_binding)
      else
        new(_binding)
      end
    end

    def initialize(_binding)
      @b = _binding
    end

    # Return a description of the frame (binding).
    # This is only useful for regular old bindings that have not been
    # enhanced by `#of_caller`.
    # @return [String] A description of the frame (binding).
    def _description
      return b.frame_description if b.frame_description

      if is_method?
        _method.to_s
      elsif b.receiver.instance_of?(Module)
        "<module:#{b.receiver}>"
      elsif b.receiver.instance_of?(Class)
        "<class:#{b.receiver}>"
      else
        "<main>"
      end
    end

    DESCRIPTION_PATTERN = %r{
      (?<context>
        (?:
          block\s
          (?:\(\d\ levels\)\ )?
        )
        (?:in\ )
      )?
      (?<method>.*)
    }x

    def description
      return unless _description
      _description.match(DESCRIPTION_PATTERN).named_captures
    end

    module T
      extend Pry::Helpers::Text

      # Not in Pry yet
      def self.faded(text)
        "\e[2m#{text}\e[0m"
      end
    end

    COLOR_SCHEME = {
      description: {
        context: :default,
        method: :green,
      },
      signature: {
        module: :default,
        method: [:blue, :bold],
        arguments: :blue,
      }
    }

    # faded(" | ")
    PIPE = "\e[2m | \e[0m"

    def apply_color(string, color = nil, weight = nil)
      return unless string

      string = T.public_send(weight, string) if weight
      string = T.public_send(color, string) if color

      string
    end

    # Produces a string describing the frame
    # @param [Options] verbose: Whether to generate a verbose description.
    # @return [String] The description of the binding.
    def info(verbose: false)
      return @info[!!verbose] if @info

      @info = _info
      @info[!!verbose]
    end

    def _info
      output = {}
      output[:type] = T.faded(type.to_s.ljust(10))

      output[:full_description] = [
        # description
        [
          apply_color(description["context"], nil),
          apply_color(description["method"], :green),
        ].compact.join(""),

        # signature
        [
          apply_color(signature['module'], nil),
          apply_color(signature['method'], :blue, :bold),
          apply_color(signature['arguments'], :faded),
        ].compact.join("")

      ].compact.join(PIPE)

      base = output.values.join("")

      extra_info = "      in #{self_clipped} #{path}"

      {
        false => base,
        true => base + "\n" + extra_info,
      }
    end

    def type
      b.frame_type
    end

    def _method
      @_method ||= b.eval('__method__')
    end

    def is_method?
      _method &&
        _method != :__binding__ &&
        _method != :__binding_impl__
    end

    def self_clipped
      Pry.view_clip(b.receiver)
    end

    def path
      '@ ' + b.source_location.join(':')
    end

    def pry_method
      Pry::Method.from_binding(b) if _method
    end

    SIGNATURE_PATTERN = /
      (?<module>.*?)
      (?<method>[#\.].*?)
      (?<arguments>\(.*?\))
    /x

    def signature
      return {} unless pry_method
      string = self.class.method_signature_with_owner(pry_method)

      # Will match strings like `Module::Module#method(args)`
      string.match(SIGNATURE_PATTERN).named_captures
    end

    # @param [Pry::Method] pry_method The method object.
    # @return [String] Signature for the method object in Class#method format.
    def self.method_signature_with_owner(pry_method)
      if pry_method.undefined?
        return "#{pry_method.name_with_owner}(UNKNOWN) (undefined method)"
      end

      args = pry_method.parameters.inject([]) do |arr, (type, name)|
        name ||= (type == :block ? 'block' : "arg#{arr.size + 1}")
        arr << case type
               when :req   then name.to_s
               when :opt   then "#{name}=?"
               when :rest  then "*#{name}"
               when :block then "&#{name}"
               else '?'
               end
      end
      "#{pry_method.name_with_owner}(#{args.join(', ')})"
    end
  end
end
