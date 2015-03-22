# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 's3_server/version'

Gem::Specification.new do |spec|
  spec.name          = 's3_server'
  spec.version       = S3Server::VERSION
  spec.authors       = ['mdouchement']
  spec.email         = ['marc.douchement@predicsis.com']
  spec.summary       = %(q{S3 Server})
  spec.description   = %(q{S3-server is a Rails server that responds to the same calls Amazon S3 responds to.})
  spec.homepage      = 'https://github.com/PredicSis/s3-server'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%(r{^bin/})) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%(r{^(test|spec|features)/}))
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.1'

  spec.add_dependency 'rails', '~> 4.2.0'
  spec.add_dependency 'sqlite3'
  spec.add_dependency 'rack-cors', '0.2.9'
  spec.add_dependency 'carrierwave', '0.10.0'
  spec.add_dependency 'tilt', '1.4.1'
  spec.add_dependency 'puma', '2.9.1'
  spec.add_dependency 'dante'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rspec', '3.2.0'
  spec.add_development_dependency 'rubocop', '0.20.0'
  spec.add_development_dependency 'codeclimate-test-reporter'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'spring'
end
