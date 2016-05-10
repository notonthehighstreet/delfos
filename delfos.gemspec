# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "delfos/version"

Gem::Specification.new do |spec|
  spec.name          = "delfos"
  spec.version       = Delfos::VERSION
  spec.authors       = ["Mark Burns"]
  spec.email         = ["markburns@notonthehighstreet.com"]

  spec.summary       = "Record every method call in an application"
  spec.description   = "Just because"
  spec.homepage      = "https://github.com/markburns/delfos"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency "binding_of_caller"

  spec.add_development_dependency "what_weve_got_here_is_an_error_to_communicate"
  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "rake", "~> 11.1.1"
  spec.add_development_dependency "rspec", "~> 3.4.0"
end
