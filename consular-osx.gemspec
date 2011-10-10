# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "consular-osx"
  s.version     = '1.0.0'
  s.authors     = ["Arthur Chiu"]
  s.email       = ["mr.arthur.chiu@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Mac OSX Terminal core for Consular}
  s.description = %q{Automate Mac OSX Terminal with Consular}

  s.rubyforge_project = "consular-osx"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'rb-appscript'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'mocha'
end
