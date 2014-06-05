# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require 'simplecov'
SimpleCov.start 'rails'

require File.expand_path("../dummy/config/environment", __FILE__)

require 'sidekiq/testing'
require 'database_cleaner'
require 'rspec/rails'
require 'shoulda/matchers'
require 'webmock/rspec'
require 'factory_girl_rails'
require 'fakeredis'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

WebMock.disable_net_connect!(:allow_localhost => true)

ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

DatabaseCleaner.strategy = :truncation

RSpec.configure do |config|
  config.color = true
  config.formatter = :documentation # :progress, :html, :textmate
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end


end
