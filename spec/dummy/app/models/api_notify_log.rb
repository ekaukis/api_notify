class ApiNotifyLog < ActiveRecord::Base
  belongs_to :api_notify_logable, polymorphic: true

  validates :endpoint, uniqueness: { scope: [:api_notify_logable_id, :api_notify_logable_type] }
end
