Gem::Specification.new do |s|
  s.name        = 'motion-launchimages'
  s.version     = '0.0.1'
  s.summary     = 'Automate RubyMotion launch images'
  s.description = 'Automate RubyMotion launch images'
  s.homepage    = 'https://github.com/brendanjcaffrey/motion-launchimages'
  s.authors     = ['Brendan J. Caffrey']
  s.email       = ['brendan@jcaffrey.com']
  s.license     = 'MIT'

  files = ['README.md', 'motion-launchimages.gemspec']
  files.concat(Dir.glob('lib/**/*.rb'))
  s.files         = files
  s.require_paths = ['lib']
  s.add_development_dependency 'rake'
end
