class ApiNotifyLog < ActiveRecord::Base
  belongs_to :api_notify_logable, polymorphic: true
end
