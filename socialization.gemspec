# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "socialization/version"

Gem::Specification.new do |s|
  s.name = "socialization"
  s.version = Socialization::VERSION
  s.authors = ["Carl Mercier"]
  s.email = "carl@carlmercier.com"
  s.homepage = "https://github.com/cmer/socialization"
  s.summary = "Easily socialize your app with Likes and Follows"
  s.description = "Socialization allows any model to Follow and/or Like any other model. This is accomplished through a double polymorphic relationship on the Follow and Like models. But you don't need to know that since all the complexity is hidden from you."
  s.license = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "activerecord"

  s.add_development_dependency "appraisal"
  s.add_development_dependency "logger"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rspec-mocks"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "yard"
  s.add_development_dependency "mock_redis"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-rspec"
end
