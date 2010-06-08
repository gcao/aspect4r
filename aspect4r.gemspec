# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{aspect4r}
  s.version = "0.7.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Guoliang Cao"]
  s.date = %q{2010-06-08}
  s.description = %q{AOP for ruby - use before_method, after_method and around_method to trim your fat methods and reduce code duplication}
  s.email = %q{gcao99@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "NOTES.rdoc",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "aspect4r.gemspec",
     "examples/after_example.rb",
     "examples/around_example.rb",
     "examples/before_example.rb",
     "examples/combined_example.rb",
     "lib/aspect4r.rb",
     "lib/aspect4r/after.rb",
     "lib/aspect4r/around.rb",
     "lib/aspect4r/base.rb",
     "lib/aspect4r/before.rb",
     "lib/aspect4r/classic.rb",
     "lib/aspect4r/errors.rb",
     "lib/aspect4r/extensions/class_extension.rb",
     "lib/aspect4r/extensions/module_extension.rb",
     "lib/aspect4r/helper.rb",
     "lib/aspect4r/model/advice.rb",
     "lib/aspect4r/model/advice_metadata.rb",
     "lib/aspect4r/model/advices_for_method.rb",
     "lib/aspect4r/model/aspect_data.rb",
     "lib/aspect4r/return_this.rb",
     "spec/aspect4r/after_spec.rb",
     "spec/aspect4r/around_spec.rb",
     "spec/aspect4r/before_spec.rb",
     "spec/aspect4r/class_inheritance_spec.rb",
     "spec/aspect4r/classic_spec.rb",
     "spec/aspect4r/helper_spec.rb",
     "spec/aspect4r/inheritance_inclusion_combined_spec.rb",
     "spec/aspect4r/module_inclusion_spec.rb",
     "spec/aspect4r/super_in_method_spec.rb",
     "spec/aspect4r_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "test/after_test.rb",
     "test/around_test.rb",
     "test/before_test.rb",
     "test/combined_test.rb",
     "test/method_invocation_test.rb",
     "test/test_helper.rb"
  ]
  s.homepage = %q{http://github.com/gcao/aspect4r}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Aspect Oriented Programming for ruby}
  s.test_files = [
    "spec/aspect4r/after_spec.rb",
     "spec/aspect4r/around_spec.rb",
     "spec/aspect4r/before_spec.rb",
     "spec/aspect4r/class_inheritance_spec.rb",
     "spec/aspect4r/classic_spec.rb",
     "spec/aspect4r/helper_spec.rb",
     "spec/aspect4r/inheritance_inclusion_combined_spec.rb",
     "spec/aspect4r/module_inclusion_spec.rb",
     "spec/aspect4r/super_in_method_spec.rb",
     "spec/aspect4r_spec.rb",
     "spec/spec_helper.rb",
     "test/after_test.rb",
     "test/around_test.rb",
     "test/before_test.rb",
     "test/combined_test.rb",
     "test/method_invocation_test.rb",
     "test/test_helper.rb",
     "examples/after_example.rb",
     "examples/around_example.rb",
     "examples/before_example.rb",
     "examples/combined_example.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
  end
end

