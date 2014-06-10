module ApiNotify
  class Task < ActiveRecord::Base
    self.table_name = :api_notify_tasks

    belongs_to :api_notifiable, polymorphic: true

    serialize :fields_updated, Array
    serialize :identificators, Hash

    after_create :perform_task

    def synchronize
      synchronizer = api_notifiable_type.constantize.synchronizer
      synchronizer.set_params(attributes)
      synchronizer.send_request(method.upcase, false, endpoint)

      send_callback(synchronizer) unless method == "delete"
      update_attributes(done: synchronizer.success?, response: synchronizer.response.to_json)
    end

    def send_callback synchronizer
      api_notifiable.disable_api_notify
      if synchronizer.success?
        api_notifiable.send("#{endpoint}_api_notify_#{method}_success", synchronizer.response)
        update_api_notify_log
      else
        api_notifiable.send("#{endpoint}_api_notify_#{method}_failed", synchronizer.response)
      end
      api_notifiable.enable_api_notify
    end

    def attributes
      (identificators.merge(api_notifiable.fill_fields_with_values(fields_updated)) if api_notifiable) || identificators
    end

    def update_api_notify_log
      log = api_notifiable.api_notify_logs.find_or_initialize_by(endpoint: endpoint)
      log.new_record? ? log.save : log.touch
    end

    def perform_task
      SynchronizerWorker.perform_async(id)
    end
  end
end
