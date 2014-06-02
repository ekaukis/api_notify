module ApiNotify
  class Railtie < ::Rails::Railtie
    initializer 'apinotify.initialize' do
      require 'sidekiq'
      require "api_notify/active_record/main"
      require "api_notify/active_record/logger"
      file_param = Rails.env == "test" ? 'w' : 'a'
      logfile = File.open("#{Rails.root}/log/api_notify_#{Rails.env}.log", file_param)
      logfile.sync = true
      ApiNotify::LOGGER = ApiNotify::ActiveRecord::Logger.new(logfile)

      ApiNotify::Hooks.init
    end
  end
end
