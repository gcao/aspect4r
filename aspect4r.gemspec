# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{aspect4r}
  s.version = "0.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Guoliang Cao"]
  s.date = %q{2011-04-29}
  s.description = %q{AOP for ruby - use before, after and around to trim your fat methods and reduce code duplication}
  s.email = %q{gcao99@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "aspect4r.gemspec",
    "examples/advices_on_class_method_example.rb",
    "examples/after_example.rb",
    "examples/around_example.rb",
    "examples/before_example.rb",
    "examples/combined_example.rb",
    "examples/test_advices_example.rb",
    "lib/aspect4r.rb",
    "lib/aspect4r/after.rb",
    "lib/aspect4r/around.rb",
    "lib/aspect4r/base.rb",
    "lib/aspect4r/before.rb",
    "lib/aspect4r/classic.rb",
    "lib/aspect4r/errors.rb",
    "lib/aspect4r/helper.rb",
    "lib/aspect4r/model/advice.rb",
    "lib/aspect4r/model/advice_metadata.rb",
    "lib/aspect4r/model/advices_for_method.rb",
    "lib/aspect4r/model/aspect_data.rb",
    "lib/aspect4r/return_this.rb",
    "spec/aspect4r/advice_group_spec.rb",
    "spec/aspect4r/advice_on_class_method_spec.rb",
    "spec/aspect4r/advice_scope_spec.rb",
    "spec/aspect4r/advice_spec.rb",
    "spec/aspect4r/advice_test_spec.rb",
    "spec/aspect4r/advices_for_method_spec.rb",
    "spec/aspect4r/after_spec.rb",
    "spec/aspect4r/around_spec.rb",
    "spec/aspect4r/before_spec.rb",
    "spec/aspect4r/class_inheritance_spec.rb",
    "spec/aspect4r/classic_spec.rb",
    "spec/aspect4r/helper_spec.rb",
    "spec/aspect4r/include_advices_from_module_spec.rb",
    "spec/aspect4r/inheritance_inclusion_combined_spec.rb",
    "spec/aspect4r/method_added_spec.rb",
    "spec/aspect4r/module_inclusion_spec.rb",
    "spec/aspect4r/singleton_method_added_spec.rb",
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
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.4.2}
  s.summary = %q{Aspect Oriented Programming for ruby}
  s.test_files = [
    "examples/advices_on_class_method_example.rb",
    "examples/after_example.rb",
    "examples/around_example.rb",
    "examples/before_example.rb",
    "examples/combined_example.rb",
    "examples/test_advices_example.rb",
    "spec/aspect4r/advice_group_spec.rb",
    "spec/aspect4r/advice_on_class_method_spec.rb",
    "spec/aspect4r/advice_scope_spec.rb",
    "spec/aspect4r/advice_spec.rb",
    "spec/aspect4r/advice_test_spec.rb",
    "spec/aspect4r/advices_for_method_spec.rb",
    "spec/aspect4r/after_spec.rb",
    "spec/aspect4r/around_spec.rb",
    "spec/aspect4r/before_spec.rb",
    "spec/aspect4r/class_inheritance_spec.rb",
    "spec/aspect4r/classic_spec.rb",
    "spec/aspect4r/helper_spec.rb",
    "spec/aspect4r/include_advices_from_module_spec.rb",
    "spec/aspect4r/inheritance_inclusion_combined_spec.rb",
    "spec/aspect4r/method_added_spec.rb",
    "spec/aspect4r/module_inclusion_spec.rb",
    "spec/aspect4r/singleton_method_added_spec.rb",
    "spec/aspect4r/super_in_method_spec.rb",
    "spec/aspect4r_spec.rb",
    "spec/spec_helper.rb",
    "test/after_test.rb",
    "test/around_test.rb",
    "test/before_test.rb",
    "test/combined_test.rb",
    "test/method_invocation_test.rb",
    "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
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

