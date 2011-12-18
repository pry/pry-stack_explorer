# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "pry-stack_explorer"
  s.version = "0.2.7pre1"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["John Mair (banisterfiend)"]
  s.date = "2011-12-19"
  s.description = "Walk the stack in a Pry session"
  s.email = "jrmair@gmail.com"
  s.files = ["lib/pry-stack_explorer/commands.rb", "lib/pry-stack_explorer/frame_manager.rb", "lib/pry-stack_explorer/version.rb", "lib/pry-stack_explorer.rb", "test/test.rb", "CHANGELOG", "README.md", "Rakefile"]
  s.homepage = "https://github.com/banister"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "Walk the stack in a Pry session"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<binding_of_caller>, ["~> 0.6.1"])
      s.add_development_dependency(%q<bacon>, ["~> 1.1.0"])
    else
      s.add_dependency(%q<binding_of_caller>, ["~> 0.6.1"])
      s.add_dependency(%q<bacon>, ["~> 1.1.0"])
    end
  else
    s.add_dependency(%q<binding_of_caller>, ["~> 0.6.1"])
    s.add_dependency(%q<bacon>, ["~> 1.1.0"])
  end
end
