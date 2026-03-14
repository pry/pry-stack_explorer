# -*- encoding: utf-8 -*-
# stub: pry-stack_explorer 0.6.2 ruby lib

Gem::Specification.new do |s|
  s.name = "pry-stack_explorer".freeze
  s.version = "0.6.2".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.required_ruby_version = ">= 2.6"
  s.require_paths = ["lib".freeze]
  s.authors = ["John Mair (banisterfiend)".freeze]
  s.date = "2026-03-13"
  s.description = "Walk the stack in a Pry session".freeze
  s.email = "jrmair@gmail.com".freeze
  s.files = [".gemtest".freeze, ".gitignore".freeze, ".rspec".freeze, ".travis.yml".freeze, ".yardopts".freeze, "CHANGELOG".freeze, "Gemfile".freeze, "LICENSE".freeze, "README.md".freeze, "Rakefile".freeze, "bin/rspec".freeze, "examples/example.rb".freeze, "examples/example2.rb".freeze, "examples/example3.rb".freeze, "lib/pry-stack_explorer.rb".freeze, "lib/pry-stack_explorer/commands.rb".freeze, "lib/pry-stack_explorer/frame_manager.rb".freeze, "lib/pry-stack_explorer/version.rb".freeze, "lib/pry-stack_explorer/when_started_hook.rb".freeze, "pry-stack_explorer.gemspec".freeze, "test/commands_test.rb".freeze, "test/frame_manager_test.rb".freeze, "test/stack_explorer_test.rb".freeze, "test/support/bingbong.rb".freeze, "test/support/input_tester.rb".freeze, "test/support/io_utils.rb".freeze, "test/support/reset_helper.rb".freeze, "test/test_helper.rb".freeze]
  s.homepage = "https://github.com/pry/pry-stack_explorer".freeze
  s.rubygems_version = "3.6.9".freeze
  s.summary = "Walk the stack in a Pry session".freeze
  s.test_files = ["test/commands_test.rb".freeze, "test/frame_manager_test.rb".freeze, "test/stack_explorer_test.rb".freeze, "test/support/bingbong.rb".freeze, "test/support/input_tester.rb".freeze, "test/support/io_utils.rb".freeze, "test/support/reset_helper.rb".freeze, "test/test_helper.rb".freeze]

  s.specification_version = 4

  s.add_runtime_dependency(%q<binding_of_caller>.freeze, [">= 1.0".freeze])
  s.add_runtime_dependency(%q<pry>.freeze, ["~> 0.13".freeze])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.9".freeze])
  s.add_development_dependency(%q<rake>.freeze, ["~> 0.9".freeze])
end
