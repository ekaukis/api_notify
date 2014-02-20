#require 'active_support/logger'

module ApiNotify
  module ActiveRecord
    class Logger < Logger
      def format_message(severity, timestamp, progname, msg)
        "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n"
      end
    end
  end
end
