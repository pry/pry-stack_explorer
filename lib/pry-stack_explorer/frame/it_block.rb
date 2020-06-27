module PryStackExplorer
  class Frame
    class ItBlock < self
      def description
        if is_method?
          pry_method.name
        else
          it_description
        end
      end

      # it "does fun things"
      def it_description
        if metadata[:location]
          "it " + metadata[:description]&.inspect
        else
          "it (anonymous)"
        end
      end

      def sig
        super || metadata[:class_name]
      end

      def type
        if is_method?
          super || "block"
        else
          "it"
        end
      end

      # Matches:
      # #<RSpec::ExampleGroups::ThatClass::Fun "does the fun" (./test/rspec_spec.rb:9)>
      # #<RSpec::ExampleGroups::ThatClass::Fun "example at ./test/rspec_spec.rb:12">
      INSPECT_REGEXP = %r{
        \#<
        (?<class_name>.+?)
        (
          \s"
          (?<description>.*?)
          "
        )?
        (
          \s\(
          (?<location>.*?)
          \)
        )?
        >
      }x

      def metadata
        @metadata ||= b.receiver.inspect
          .match(INSPECT_REGEXP)
          .named_captures.transform_keys(&:to_sym)
      end
    end
  end
end
