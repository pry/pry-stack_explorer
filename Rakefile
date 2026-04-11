require "bundler/gem_tasks"

$:.unshift 'lib'

direc = File.dirname(__FILE__)

require 'rake/clean'

CLOBBER.include("**/*~", "**/*#*", "**/*.log")
CLEAN.include("**/*#*", "**/*#*.*", "**/*_flymake*.*", "**/*_flymake",
              "**/*.rbc", "**/.#*.*")

desc "run pry with plugin enabled"
task :pry do
  exec("pry -I#{direc}/lib/ -r #{direc}/lib/pry-stack_explorer")
end

desc "Run example"
task :example do
  sh "ruby -I#{direc}/lib/ #{direc}/examples/example.rb "
end

desc "Run example2"
task :example2 do
  sh "ruby -I#{direc}/lib/ #{direc}/examples/example2.rb "
end

desc "Run example3"
task :example3 do
  sh "ruby -I#{direc}/lib/ #{direc}/examples/example3.rb "
end

desc "run tests"
task :default => :test

desc "run tests"
task :test do
  sh "rspec"
end
