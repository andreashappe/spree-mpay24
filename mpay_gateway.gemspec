Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'mpay_gateway'
  s.version     = '0.40'
  s.summary     = 'MPay24 Payment gateway for Spree 0.40+'
  #s.description = 'Add (optional) gem description here'
  s.required_ruby_version = '>= 1.8.7'

  s.author            = 'Andreas Happe'
  s.email             = 'andreashappe@starseeders.net'
  s.homepage          = 'http://www.starseeders.net'

  s.files        = Dir['CHANGELOG', 'README.md', 'LICENSE', 'lib/**/*', 'app/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'

  s.has_rdoc = true

  s.add_dependency('spree_core', '>= 0.40.2')
end
