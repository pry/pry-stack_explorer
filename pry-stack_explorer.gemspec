# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{pry-stack_explorer}
  s.version = "0.2.9pre6"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{John Mair (banisterfiend)}]
  s.date = %q{2012-01-20}
  s.description = %q{Walk the stack in a Pry session}
  s.email = %q{jrmair@gmail.com}
  s.files = [%q{.gemtest}, %q{.gitignore}, %q{.travis.yml}, %q{.yardopts}, %q{CHANGELOG}, %q{Gemfile}, %q{LICENSE}, %q{README.md}, %q{Rakefile}, %q{examples/example.rb}, %q{examples/example2.rb}, %q{lib/pry-stack_explorer.rb}, %q{lib/pry-stack_explorer/commands.rb}, %q{lib/pry-stack_explorer/frame_manager.rb}, %q{lib/pry-stack_explorer/version.rb}, %q{lib/pry-stack_explorer/when_started_hook.rb}, %q{pry-stack_explorer.gemspec}, %q{test/helper.rb}, %q{test/test_commands.rb}, %q{test/test_frame_manager.rb}, %q{test/test_stack_explorer.rb}, %q{tester.rb}]
  s.homepage = %q{https://github.com/banister}
  s.require_paths = [%q{lib}]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2")
  s.rubygems_version = %q{1.8.6}
  s.summary = %q{Walk the stack in a Pry session}
  s.test_files = [%q{test/helper.rb}, %q{test/test_commands.rb}, %q{test/test_frame_manager.rb}, %q{test/test_stack_explorer.rb}]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<binding_of_caller>, ["~> 0.6.1"])
      s.add_runtime_dependency(%q<pry>, ["= 0.9.8pre7"])
      s.add_development_dependency(%q<bacon>, ["~> 1.1.0"])
      s.add_development_dependency(%q<rake>, ["~> 0.9"])
    else
      s.add_dependency(%q<binding_of_caller>, ["~> 0.6.1"])
      s.add_dependency(%q<pry>, ["= 0.9.8pre7"])
      s.add_dependency(%q<bacon>, ["~> 1.1.0"])
      s.add_dependency(%q<rake>, ["~> 0.9"])
    end
  else
    s.add_dependency(%q<binding_of_caller>, ["~> 0.6.1"])
    s.add_dependency(%q<pry>, ["= 0.9.8pre7"])
    s.add_dependency(%q<bacon>, ["~> 1.1.0"])
    s.add_dependency(%q<rake>, ["~> 0.9"])
  end
end
