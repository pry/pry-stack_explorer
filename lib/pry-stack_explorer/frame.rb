require_relative "frame/rspec_frame"

module PryStackExplorer
  class Frame
    include Pry::Helpers::Text

    attr_reader :b

    def self.make(_binding)
      if defined?(RSpec::Core) && _binding.receiver.is_a?(RSpec::Core::ExampleGroup)
        RSpecFrame.new(_binding)
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

      base = faded(type.to_s.ljust(10)) + colored_description

      if sig
        base << faded(" | ") << colored_sig
      end

      @info = {
        false => base,
        true => base + "\n      in #{self_clipped} #{path}",
      }

      @info[!!verbose]
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

    private

    FRAME_DESC_PATTERN = /\A((?:block\s(?:\(\d levels\) )?in )?)(.*)\z/

    def colored_description
      desc = description or return ""
      m = desc.match(FRAME_DESC_PATTERN)
      m[1] + green(m[2])
    end

    def colored_sig
      return "" unless pry_method
      return sig if pry_method.undefined?

      owner, sep, name = pry_method.name_with_owner.partition(/[#.]/)
      args = sig.delete_prefix(pry_method.name_with_owner)

      owner + bold(blue("#{sep}#{name}")) + faded(args)
    end

    def faded(text)
      "\e[2m#{text}\e[0m"
    end
  end
end
