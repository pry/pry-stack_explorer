require 'rubygems'

unless Object.const_defined? 'PryStackExplorer'
  $:.unshift File.expand_path '../../lib', __FILE__
  require 'pry-stack_explorer'
end

require 'bacon'

puts "Testing pry-stack_explorer version #{PryStackExplorer::VERSION}..."
puts "Ruby version: #{RUBY_VERSION}"

PE = PryStackExplorer
