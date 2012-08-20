# -*- encoding: utf-8 -*-
require File.expand_path("../lib/elster/version", __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jason Webb"]
  gem.email         = ["bigjasonwebb@gmail.com"]
  gem.description   = %q{A simple streaming JSON encoder.}
  gem.summary       = %q{A simple streaming JSON encoder.}
  gem.homepage      = ""

  gem.files         = Dir["#{File.dirname(__FILE__)}/**/*"]
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "elster"
  gem.require_paths = ["lib"]
  gem.version       = Elster::VERSION

  gem.add_dependency "multi_json"
  gem.add_development_dependency "minitest"
  gem.add_development_dependency "turn"
end
