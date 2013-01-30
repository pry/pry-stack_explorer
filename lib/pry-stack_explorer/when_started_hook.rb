module PryStackExplorer
  class WhenStartedHook
    include Pry::Helpers::BaseHelpers

    def caller_bindings(target)
      bindings = binding.callers

      start_frames = bindings.each_with_index.select do |b, i|
        b.frame_type == :method &&
          safe_send(b.eval("self"), :equal?, Pry) &&
          safe_send(b.eval("__method__"), :==, :start)
      end

      start_frame_index = start_frames.first.last

      if start_frames.size >= 2
        idx1, idx2 = start_frames.take(2).map(&:last)

        is_nested_session = bindings[idx1..idx2].detect do |b|
          safe_send(b.eval("__method__"), :==, :re) &&
            safe_send(b.eval("self.class"), :equal?, Pry)
        end

        start_frame_index = idx2 if !is_nested_session
      end

      bindings = bindings.drop(start_frame_index + 1)
      bindings = bindings.drop_while { |b| b.eval("__FILE__") =~ /pry-(?:nav|debugger)/ }
      bindings = bindings.drop(1) if safe_send(bindings.first.eval("__method__"), :==, :pry)

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
