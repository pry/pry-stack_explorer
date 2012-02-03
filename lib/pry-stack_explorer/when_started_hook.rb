module PryStackExplorer
  class WhenStartedHook

    def caller_bindings(target)
      bindings = binding.callers

      start_frames = bindings.each_with_index.select do |b, i|
        b.frame_type == :method &&
          b.eval("self") == Pry &&
          b.eval("__method__") == :start
      end

      is_nested_session = false

      start_frame_index = start_frames.first.last

      if start_frames.size >= 2
        idx1, idx2 = start_frames.take(2).map(&:last)

        is_nested_session = bindings[idx1..idx2].detect do |b|
          b.eval("__method__") == :re &&
            b.eval("self.class") == Pry
        end

        start_frame_index = idx2 if !is_nested_session
      end

      bindings = bindings.drop(start_frame_index + 1)

      bindings = bindings.drop(1) if bindings.first.eval("__method__") == :pry
      bindings = bindings.drop(1) if bindings.first.eval("self.class.name") == "PryNav::Tracer" && bindings.first.eval("__method__") == :tracer

      # Use the binding returned by #of_caller if possible (as we get
      # access to frame_type).
      # Otherwise stick to the given binding (target).
      if !PryStackExplorer.bindings_equal?(target, bindings.first)
        bindings.shift
        bindings.unshift(target)
      end

      bindings
    end

    def call(target, options, _pry_)
      options = {
        :call_stack    => true,
        :initial_frame => 0
      }.merge!(options)

      return if !options[:call_stack]

      if options[:call_stack].is_a?(Array)
        bindings = options[:call_stack]

        if bindings.empty? || !bindings.all? { |v| v.is_a?(Binding) }
          raise ArgumentError, ":call_stack must be an array of bindings"
        end
      else
        bindings = caller_bindings(target)
      end

      PryStackExplorer.create_and_push_frame_manager bindings, _pry_, :initial_frame => options[:initial_frame]
    end
  end
end
