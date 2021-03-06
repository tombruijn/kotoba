require File.expand_path("../lib/kotoba/version", __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = [
    "Tom de Bruijn"
  ]
  gem.email         = [
    "tom@tomdebruijn.com"
  ]
  gem.description   = "Book manager in Ruby for Markdown files. Exports to "\
                      "PDF through PrawnPDF."
  gem.summary       = "Book manager in Ruby for Markdown files. Exports to "\
                      "PDF through PrawnPDF."
  gem.homepage      = "http://github.com/tombruijn/kotoba"
  gem.license       = "MIT"

  gem.files         = `git ls-files -- lib bin support README.md LICENSE Gemfile`.split($\)
  gem.test_files    = `git ls-files -- spec`.split($\)
  gem.name          = "kotoba"
  gem.require_paths = ["lib"]
  gem.executables   = ["kotoba"]
  gem.version       = Kotoba::VERSION

  gem.add_dependency "prawn", "~> 2.0"
  gem.add_dependency "thor"
  gem.add_dependency "kramdown"
  gem.add_dependency "hashie"

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "pdf-inspector"
  gem.add_development_dependency "pry"
  gem.add_development_dependency "simplecov"
end
