lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'path_mapper/version'

Gem::Specification.new do |spec|
  spec.name          = "path_mapper"
  spec.version       = PathMapper::VERSION
  spec.authors       = ["Alexey Igrychev"]
  spec.email         = ["alexey.igrychev@flant.ru"]
  spec.summary       = "Map filesystem to ruby objects read-only."
  spec.description   = spec.summary
  spec.license       = "MIT"
  spec.homepage      = "https://github.com/flant/path_mapper"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.4', '>= 3.4.0'
  spec.add_development_dependency 'travis', '~> 1.8', '>= 1.8.2'
end
