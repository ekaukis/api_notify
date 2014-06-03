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

  s.add_dependency "sidekiq",           '~> 2.17.0'
  s.add_dependency "sidekiq-cron",      "~> 0.1.0"
  s.add_dependency "rails",             '~> 4.0.5'
  s.add_development_dependency "fakeredis"
  s.add_development_dependency "rspec-sidekiq"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "shoulda-matchers"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'webmock'
  s.add_development_dependency "sqlite3"
end
