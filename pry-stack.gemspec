# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name    = "pry-stack"
  s.version = File.read("VERSION").strip
  s.date    = File.mtime("VERSION").strftime("%Y-%m-%d")

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.authors     = ["John Mair (banisterfiend)", "Chris Gahan (epitron)"]
  s.email       = ["jrmair@gmail.com", "chris@ill-logic.com"]
  s.description = "Walk the stack in Pry, with STYLE."
  s.summary     = "Tired of your 'up' and 'down' commands going in the wrong direction? Longing for a shorter command to show the stack? Are your fingers raw from typing overly long gem names and unnecessary underscores? Then pry-stack is for you!"
  s.homepage    = "https://github.com/epitron/pry-stack"
  s.licenses    = ["MIT"]

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- test/*`.split("\n")
  s.extra_rdoc_files = ["README.md", "CHANGELOG"]
  s.require_paths    = ["lib"]

  s.add_dependency("binding_of_caller", "~> 0.7")
  s.add_dependency("pry", ["~> 0.9", ">= 0.9.11"])
  s.add_development_dependency("bacon", "~> 1.1")
  s.add_development_dependency("rake", "~> 0.9")
end
