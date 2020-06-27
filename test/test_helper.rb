require 'ostruct'
require 'pry'

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each do |file|
  require file
end


# unless Object.const_defined? 'PryStackExplorer'
  $:.unshift File.expand_path '../../lib', __FILE__
  require 'pry-stack_explorer'
# end

puts "Testing pry-stack_explorer version #{PryStackExplorer::VERSION}..."
puts "Ruby version: #{RUBY_VERSION}"

PE = PryStackExplorer

ResetHelper::Hooks.memoize!

RSpec.configure do |config|
  config.include IOUtils
end
