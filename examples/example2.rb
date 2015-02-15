unless Object.const_defined? :PryStack
  $:.unshift File.expand_path '../../lib', __FILE__
  require 'pry'
end

require 'pry-stack'

def alpha
  x = "hello"
  beta
  puts x
end

def beta
  binding.pry
end

alpha
