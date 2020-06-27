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
    def description
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


    # Produces a string describing the frame
    # @param [Options] verbose: Whether to generate a verbose description.
    # @return [String] The description of the binding.
    def info(verbose: false)
      return @info[!!verbose] if @info

      base = ""
      base << faded(pretty_type.ljust(9))
      base << " #{description}"

      if sig
        base << faded(" | ")
        base << sig
      end

      @info = {
        false => base,
        true => base + "\n      in #{self_clipped} #{path}",
      }

      @info[!!verbose]
    end

    def pretty_type
      type ? "[#{type}]" : ""
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

    def sig
      return unless pry_method
      self.class.method_signature_with_owner(pry_method)
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

    # Not in Pry yet
    def faded(text)
      "\e[2m#{text}\e[0m"
    end
  end
end
