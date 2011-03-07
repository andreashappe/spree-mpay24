Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'mpay_gateway'
  s.version     = '0.43'
  s.summary     = 'MPay24 Payment gateway for Spree 0.40+'
  s.description = 'Integrates the mpay24 credit card and online payment processing system into the spree web shop'
  s.required_ruby_version = '>= 1.8.7'

  s.author            = 'Andreas Happe'
  s.email             = 'andreashappe@starseeders.net'
  s.homepage          = 'http://github.com/andreashappe/spree-mpay24'

  s.files        = Dir['CHANGELOG', 'README.markdown', 'LICENSE', 'lib/**/*', 'app/**/*', 'config/**/*', 'db/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'

  s.has_rdoc = false

  s.add_dependency('spree_core', '>= 0.40.3')
end
