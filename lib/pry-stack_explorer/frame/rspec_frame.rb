module PryStackExplorer
  class Frame
    class RSpecFrame < self
      def description
        return super if is_method?

        ex = rspec_example
        if ex&.metadata&.[](:description_args)&.any?
          "it " + ex.description.inspect
        else
          "it (anonymous)"
        end
      end

      def sig
        return super if super
        ex = rspec_example or return
        full = ex.metadata[:full_description]
        full&.delete_suffix(" #{ex.description}")&.strip
      end

      def type
        if is_method?
          super || "block"
        else
          "it"
        end
      end

      def colored_sig
        return super if pry_method
        faded(sig.to_s)
      end

      private

      def rspec_example
        RSpec.current_example if defined?(RSpec)
      end
    end
  end
end
