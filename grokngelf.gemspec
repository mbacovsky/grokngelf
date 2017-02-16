# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "grokngelf/version"

Gem::Specification.new do |s|

  s.name          = "grokngelf"
  s.version       = GrokNGelf.version.dup
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["Martin Bačovský"]
  s.email         = "mbacovsk@redhat.com"
  s.homepage      = ""
  s.license       = "GPL-3"

  s.summary       = %q{Universal command-line interface}
  s.description   = <<EOF
Hammer cli provides universal extendable CLI interface for ruby apps
EOF

  s.files            = Dir['{lib,test,bin,doc,config,locale}/**/*', 'LICENSE', 'README*']
  s.test_files       = Dir['test/**/*']
  s.extra_rdoc_files = Dir['{doc,config}/**/*', 'README*']
  s.require_paths = ["lib"]
  s.executables = ['grokngelf']

  s.add_dependency 'clamp', '~> 1.0'
  s.add_dependency 'awesome_print'
  s.add_dependency 'gelf'
  s.add_dependency 'jls-grok'
end
