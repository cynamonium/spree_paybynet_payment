# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_paybynet_payment'
  s.version     = '0.0.1'
  s.summary     = 'Paybynet payment system for Spree'
  s.required_ruby_version = '>= 1.9'

  s.author            = 'Piotr Karbownik'
  s.email             = 'cynamonium@gmail.com'


  s.files        = Dir['CHANGELOG', 'README.md', 'LICENSE', 'lib/**/*', 'app/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'

  s.has_rdoc = true

  s.add_dependency('spree_core', '>= 0.30.0')
end
