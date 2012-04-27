# -*- encoding: utf-8 -*-
require File.expand_path('../lib/wd_sinatra/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Matt Aimonetti"]
  gem.email         = ["mattaimonetti@gmail.com"]
  gem.description   = %q{Weasel-Diesel Sinatra app gem, allowing you to generate/update sinatra apps using the Weasel Diesel DSL}
  gem.summary       = %q{Weasel-Diesel Sinatra app gem, allowing you to generate/update sinatra apps using the Weasel Diesel DSL}
  gem.homepage      = "https://github.com/mattetti/wd_sinatra"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "wd_sinatra"
  gem.require_paths = ["lib"]
  gem.version       = WD::Sinatra::VERSION

  gem.add_dependency('weasel_diesel')
  gem.add_dependency('thor')
end


