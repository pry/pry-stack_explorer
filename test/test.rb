direc = File.dirname(__FILE__)

require 'rubygems'
require "#{direc}/../lib/pry-stack_explorer"
require 'bacon'

puts "Testing pry-stack_explorer version #{PryStackExplorer::VERSION}..."
puts "Ruby version: #{RUBY_VERSION}"

describe PryStackExplorer do
end

