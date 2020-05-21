module PryStackExplorer
  # Ruby 2.6 introduced Binding.source_location, and Ruby 2.7 made it a warning
  # to eval __FILE__ or __LINE__. This file exists to handle getting the file or
  # line number silently regardless of ruby version.
  module LocationHelper

    module_function
    def source_file(b = binding)
      return b.source_location.first if b.respond_to?(:source_location)
      b.eval("__FILE__")
    end

    module_function
    def source_line(b = binding)
      return b.source_location[1] if b.respond_to?(:source_location)
      b.eval("__LINE__")
    end
  end
end
