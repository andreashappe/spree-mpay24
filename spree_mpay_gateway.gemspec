# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_mpay_gateway'
  s.version     = '1.1.1'
  s.summary     = 'mpay24 payment gateway for spree'
  s.description = 'Integrates the mpay24 credit and online payment processing system into the spree ecommerce solution'
  s.required_ruby_version = '>= 1.8.7'

  s.author    = 'Andreas Happe'
  s.email     = 'andreas.happe@starseeders.net'
  s.homepage  = 'http://www.starseeders.net'

  #s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 1.1.1'

  s.add_development_dependency 'capybara', '1.0.1'
  s.add_development_dependency 'factory_girl', '~> 2.6.4'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 2.9'
  s.add_development_dependency 'sqlite3'
end
