require File.expand_path('../lib/pry-stack_explorer/version', __FILE__)

Gem::Specification.new do |s|
  s.name = "pry-stack_explorer"
  s.version = PryStackExplorer::VERSION

  s.required_ruby_version = ">= 2.0.0"
  s.authors = ["John Mair (banisterfiend)"]
  s.email = "jrmair@gmail.com"

  s.license = "MIT"

  s.summary = "Walk the stack in a Pry session"

  s.files = [".gemtest", ".gitignore", ".travis.yml", ".yardopts", "CHANGELOG", "Gemfile", "LICENSE", "README.md", "Rakefile", "examples/example.rb", "examples/example2.rb", "examples/example3.rb", "lib/pry-stack_explorer.rb", "lib/pry-stack_explorer/commands.rb", "lib/pry-stack_explorer/frame_manager.rb", "lib/pry-stack_explorer/version.rb", "lib/pry-stack_explorer/when_started_hook.rb", "pry-stack_explorer.gemspec", "test/helper.rb", "test/test_commands.rb", "test/test_frame_manager.rb", "test/test_stack_explorer.rb", "tester.rb"]
  s.require_paths = ["lib"]
  s.test_files = ["test/helper.rb", "test/test_commands.rb", "test/test_frame_manager.rb", "test/test_stack_explorer.rb"]

  s.homepage = "https://github.com/pry/pry-stack_explorer"

  s.specification_version = 4

  s.add_runtime_dependency 'binding_of_caller', '~> 0.7'
  s.add_runtime_dependency 'pry', '~> 0.13'

  s.add_development_dependency 'bacon', '~> 1.1.0'
  s.add_development_dependency 'rake', '~> 0.9'
end
