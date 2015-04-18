# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'emmy_http/client/version'

Gem::Specification.new do |spec|
  spec.name          = "emmy-http-client"
  spec.version       = EmmyHttp::Client::VERSION
  spec.authors       = ["inre"]
  spec.email         = ["inre.storm@gmail.com"]

  spec.summary       = %q{HTTP Client}
  spec.description   = %q{EventMachine-based HTTP Client}
  #spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "event_object"
  spec.add_dependency "fibre"
  #spec.add_dependency "emmy-machine"
  #spec.add_dependency "emmy-http"

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
end
