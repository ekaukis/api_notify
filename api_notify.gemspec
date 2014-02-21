$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "api_notify/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "api_notify"
  s.version     = ApiNotify::VERSION
  s.authors     = ["Edgars Kaukis"]
  s.email       = ["e.kaukis@gmail.com"]
  s.licenses    = 'MIT'
  s.homepage    = "https://github.com/ekaukis/api_notify"
  s.summary     = "ApiNotify allows to comunicate between two systems via API"
  s.description = "ApiNotify is an ActiveRecord extender. Based on model callbacks, api_notify knows if it needs to send request."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.test_files    = s.files.grep(/^spec\//)
  s.require_path = "lib"

  s.add_development_dependency "rails",               '~> 3.0'
  s.add_development_dependency "rspec-rails",         "~> 2.10"
  s.add_development_dependency "factory_girl_rails",  "~> 4.4"
  s.add_development_dependency 'simplecov',           '~> 0.7.1'
  s.add_development_dependency 'database_cleaner',    '~> 0.8.0'
  s.add_development_dependency 'webmock',             '~> 1.0'
  s.add_development_dependency "sqlite3",             "~> 1.3.8"
end
