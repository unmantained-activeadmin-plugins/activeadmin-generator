# -*- encoding: utf-8 -*-
require File.expand_path('../lib/active_admin/generator/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Stefano Verna"]
  gem.email         = ["stefano.verna@welaika.com"]
  gem.description   = %q{Generate ActiveAdmin projects}
  gem.summary       = %q{Generate ActiveAdmin projects}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "activeadmin-generator"
  gem.require_paths = ["lib"]
  gem.version       = ActiveAdmin::Generator::VERSION

  gem.add_dependency "rake"
  gem.add_dependency "thor"
  gem.add_dependency "railties"
  gem.add_dependency "s3"
  gem.add_dependency "heroku-api"
  gem.add_dependency "mechanize"
end

