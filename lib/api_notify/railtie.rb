module ApiNotify
  class Railtie < ::Rails::Railtie
    initializer 'apinotify.initialize' do
      require "api_notify/active_record/logger"
      logfile = File.open("#{Rails.root}/log/api_notify.log", 'a')
      logfile.sync = true
      ApiNotify::LOGGER = ApiNotify::ActiveRecord::Logger.new(logfile)

      ApiNotify::Hooks.init
    end
  end
end
