# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{fast_innodb_import}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tobias Schwab"]
  s.date = %q{2010-09-23}
  s.default_executable = %q{fast_innodb_import}
  s.description = %q{Script to import mysqldumps (<table_name>.txt files created with option -T) with "disabled" keys (like DISABLE KEYS for MyISAM Tables)}
  s.email = ["tobias.schwab@dynport.de"]
  s.executables = ["fast_innodb_import"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt"]
  s.files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "lib/fast_innodb_import.rb", "script/console", "script/destroy", "script/generate", "spec/fast_innodb_import_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "tasks/rspec.rake", "bin/fast_innodb_import"]
  s.homepage = %q{http://github.com/dynport/fast_innodb_import}
  s.post_install_message = %q{PostInstall.txt}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{fast_innodb_import}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Script to import mysqldumps (<table_name>.txt files created with option -T) with "disabled" keys (like DISABLE KEYS for MyISAM Tables)}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mysql2>, [">= 0.1.9"])
      s.add_development_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_development_dependency(%q<hoe>, [">= 2.6.2"])
    else
      s.add_dependency(%q<mysql2>, [">= 0.1.9"])
      s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_dependency(%q<hoe>, [">= 2.6.2"])
    end
  else
    s.add_dependency(%q<mysql2>, [">= 0.1.9"])
    s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
    s.add_dependency(%q<hoe>, [">= 2.6.2"])
  end
end
