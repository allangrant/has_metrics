require File.expand_path('../lib/has_metrics/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Allan Grant"]
  gem.email         = ["allan@allangrant.net"]
  gem.description   = %q{Calculate metrics on activerecord entries and cache them.}
  gem.summary       = %q{Calculate metrics on activerecord entries and cache them.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "has_metrics"
  gem.require_paths = ["lib"]
  gem.version       = HasMetrics::VERSION
  
  gem.add_development_dependency("rake")
end
