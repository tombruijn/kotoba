# encoding: utf-8

require File.expand_path("../lib/kotoba/version", __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = [
    "Tom de Bruijn"
  ]
  gem.email         = [
    "tom@tomdebruijn.com"
  ]
  gem.description   = "Book manager in Ruby"
  gem.summary       = "Book manager in Ruby"
  gem.homepage      = "http://github.com/machinery/kotoba"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "kotoba"
  gem.require_paths = ["lib"]
  gem.executables   = ["kotoba"]
  gem.version       = Kotoba::VERSION

  gem.add_dependency "prawn"
  gem.add_dependency "thor"
  gem.add_dependency "maruku"
  gem.add_dependency "htmlentities"
  gem.add_dependency "hashie"

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "pry"
  gem.add_development_dependency "simplecov"
end
