# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "pry-stack"
  s.version = "0.4.9.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["John Mair (banisterfiend)", "Chris Gahan (epitron)"]
  s.email = ["jrmair@gmail.com", "chris@ill-logic.com"]
  s.date = "2015-02-12"

  s.description = "Walk the stack in Pry, with STYLE."
  s.summary = "Tired of your 'up' and 'down' commands going in the wrong direction? Longing for a shorter command to show the stack? Are your fingers raw from typing overly long gem names and unnecessary underscores? Then pry-stack is for you!"

  s.files = [".gemtest", ".gitignore", ".travis.yml", ".yardopts", "CHANGELOG", "Gemfile", "LICENSE", "README.md", "Rakefile", "examples/example.rb", "examples/example2.rb", "examples/example3.rb", "lib/pry-stack_explorer.rb", "lib/pry-stack_explorer/commands.rb", "lib/pry-stack_explorer/frame_manager.rb", "lib/pry-stack_explorer/version.rb", "lib/pry-stack_explorer/when_started_hook.rb", "pry-stack_explorer.gemspec", "test/helper.rb", "test/test_commands.rb", "test/test_frame_manager.rb", "test/test_stack_explorer.rb", "tester.rb"]
  s.homepage = "https://github.com/epitron/pry-stack"
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"

  s.test_files = ["test/helper.rb", "test/test_commands.rb", "test/test_frame_manager.rb", "test/test_stack_explorer.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<binding_of_caller>, [">= 0.7"])
      s.add_runtime_dependency(%q<pry>, [">= 0.9.11"])
      s.add_development_dependency(%q<bacon>, ["~> 1.1.0"])
      s.add_development_dependency(%q<rake>, ["~> 0.9"])
    else
      s.add_dependency(%q<binding_of_caller>, [">= 0.7"])
      s.add_dependency(%q<pry>, [">= 0.9.11"])
      s.add_dependency(%q<bacon>, ["~> 1.1.0"])
      s.add_dependency(%q<rake>, ["~> 0.9"])
    end
  else
    s.add_dependency(%q<binding_of_caller>, [">= 0.7"])
    s.add_dependency(%q<pry>, [">= 0.9.11"])
    s.add_dependency(%q<bacon>, ["~> 1.1.0"])
    s.add_dependency(%q<rake>, ["~> 0.9"])
  end
end
