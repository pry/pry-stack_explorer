unless Object.const_defined? :PryStack
  $:.unshift File.expand_path '../../lib', __FILE__
  require 'pry'
end

require 'pry-stack'

def alphabet(y)
  x = 20
  b
end

def b
  x = 30
  proc {
    c
  }.call
end

def c
  u = 50
  binding.pry
end

# hello
def beta
  gamma
end

def gamma
  zeta
end

def zeta
  vitamin = 100
  binding.pry
end
#

proc {
  class J
    alphabet(22)
  end
}.call

