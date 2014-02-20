$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "api_notify/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "api_notify"
  s.version     = ApiNotify::VERSION
  s.authors     = ["Edgars Kaukis"]
  s.email       = ["e.kaukis@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of ApiNotify."
  s.description = "TODO: Description of ApiNotify."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]


  s.add_development_dependency "bundler", "~> 1.5"
  s.add_development_dependency "rake"
  s.add_development_dependency "rails",       ">= 3.0"
  s.add_development_dependency "rspec-rails", "~> 2.0"
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'webmock'
  s.add_development_dependency "sqlite3"
end
