module ApiNotify
  class Log < ActiveRecord::Base
    self.table_name = :api_notify_logs

    belongs_to :api_notify_logable, polymorphic: true

    validates :endpoint, uniqueness: { scope: [:api_notify_logable_id, :api_notify_logable_type] }
  end
end
