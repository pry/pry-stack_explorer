require File.expand_path('../lib/pry-stack_explorer/version', __FILE__)

Gem::Specification.new do |s|
  s.name = "pry-stack_explorer"
  s.version = PryStackExplorer::VERSION

  s.required_ruby_version = ">= 2.6.0"

  s.authors = ["John Mair (banisterfiend)"]
  s.email = ["jrmair@gmail.com"]

  s.license = "MIT"

  s.summary = "Walk the stack in a Pry session"

  s.require_paths = ["lib"]
  s.files = `git ls-files lib *.md LICENSE`.split("\n")

  s.homepage = "https://github.com/pry/pry-stack_explorer"
  s.metadata = {
    "bug_tracker_uri" => "https://github.com/pry/pry-stack_explorer/issues",
    "source_code_uri" => "https://github.com/pry/pry-stack_explorer",
  }

  s.specification_version = 4

  s.add_runtime_dependency 'binding_of_caller', '~> 1.0'
  s.add_runtime_dependency 'pry', '~> 0.13'

  s.add_development_dependency 'rspec', '~> 3.9'
  s.add_development_dependency 'rake', '~> 0.9'
end
