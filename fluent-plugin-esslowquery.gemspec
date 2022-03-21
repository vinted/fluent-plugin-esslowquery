Gem::Specification.new do |gem|
  gem.authors       = ["Boguslaw Mista"]
  gem.email         = ["bodziomista@gmail.com"]
  gem.description   = "Fluent parser plugin for Elasticsearch slow query and slow indexing log files."
  gem.summary       = "Fluent parser plugin for Elasticsearch slow query and slow indexing log files."
  gem.homepage      = "https://github.com/iaintshine/fluent-plugin-esslowquery"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "fluent-plugin-esslowquery"
  gem.require_paths = ["lib"]
  gem.version       = "1.1.1"
  gem.add_dependency "fluentd", [">= 0.12.0", "< 2"]

  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'rspec', '~> 3.7'
end
