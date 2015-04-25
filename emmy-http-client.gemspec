# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'emmy_http/client/version'

Gem::Specification.new do |spec|
  spec.name          = "emmy-http-client"
  spec.version       = EmmyHttp::Client::VERSION
  spec.authors       = ["inre"]
  spec.email         = ["inre.storm@gmail.com"]

  spec.summary       = %q{HTTP request client}
  spec.description   = %q{EventMachine-based HTTP request client}
  #spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "http_parser.rb", "0.6.0"
  spec.add_dependency "event_object", "~> 0.9.1"
  spec.add_dependency "fibre", "~> 0.9.7"
  spec.add_dependency "emmy-machine", "~> 0.1.7"
  #spec.add_dependency "emmy-http", "~> 0.1.6"

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
end
