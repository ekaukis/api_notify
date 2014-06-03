class ApiNotifyTasks < ActiveRecord::Base
  belongs_to :api_notifiable, polymorphic: true
end
