# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'barristan/version'

Gem::Specification.new do |s|
  s.name          = "barristan"
  s.version       = Barristan::VERSION
  s.authors       = ["chatgris"]
  s.email         = ["jboyer@af83.com"]
  s.homepage      = "http://chatgris.github.com/barristan"
  s.summary       = "Ruby authorization system."
  s.description   = "Lightweight and framework-agnostic ruby authorization system."
  s.files         = `git ls-files app lib LICENSE`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.add_development_dependency "rspec"
end
