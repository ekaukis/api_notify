class ApiNotifyTask < ActiveRecord::Base
  belongs_to :api_notifiable, polymorphic: true
end
