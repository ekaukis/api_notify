module ApiNotify
  class Hooks
    def self.init
      ActiveSupport.on_load(:active_record) do
        require 'api_notify/active_record/main'
        ::ActiveRecord::Base.send :include, ApiNotify::ActiveRecord::Main
      end
    end
  end
end
