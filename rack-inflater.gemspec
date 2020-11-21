# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rack/inflater/version"

Gem::Specification.new do |spec|
  spec.name = "rack-inflater"
  spec.version = Rack::Inflater::VERSION
  spec.authors = ["Ville Lautanala"]
  spec.email = ["lautis@gmail.com"]

  spec.summary = %q{Decompress body of incoming HTTP requests.}
  spec.description = %q{Rack middleware to inflate GZip and other compressions in incoming HTTP requests.}
  spec.homepage = "https://github.com/lautis/rack-inflater"
  spec.license = "MIT"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "http_decoders", "~> 0.1.0"
  spec.add_development_dependency "rack"
  spec.add_development_dependency "bundler", ">= 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
