# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'middleman-keycdn/version'

Gem::Specification.new do |s|
  s.name        = 'middleman-keycdn'
  s.version     = Middleman::KeyCDN::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jamie Lawrence"]
  s.email       = ["jamie@ideasasylum.com"]
  s.homepage    = "https://github.com/ideasasylum/middleman-keycdn"
  s.summary     = %q{Invalidate KeyCDN cache after deployment to S3}
  s.description = %q{Adds ability to invalidate a specific set of files in your KeyCDN cache}

  s.files         = `git ls-files -z`.split("\0")
  s.test_files    = `git ls-files -z -- {fixtures,features}/*`.split("\0")
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 2.0.0'

  s.add_development_dependency 'rake', '>= 0.9.0'
  s.add_development_dependency 'rspec', '~> 3.0'

  s.add_dependency 'middleman-core', '~> 4.0'
  s.add_dependency 'middleman-cli', '~> 4.0'
  s.add_dependency 'keycdn', '~> 0.1.1'
  s.add_dependency 'ansi', '~> 1.5'
end
