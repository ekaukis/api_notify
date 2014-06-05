class ApiNotifyTask < ActiveRecord::Base
  belongs_to :api_notifiable, polymorphic: true

  serialize :fields_updated

  def synchronize
    synchronizer = api_notifiable.class.synchronizer
    synchronizer.set_params(attributes_changed.merge(api_notifiable.get_identificators))
    synchronizer.send_request(method.upcase, endpoint)

    api_notifiable.disable_api_notify
    if synchronizer.success?
      api_notifiable.send("#{endpoint}_api_notify_#{method}_success", synchronizer.response)
    else
      api_notifiable.send("#{endpoint}_api_notify_#{method}_failed", synchronizer.response)
    end
    api_notifiable.enable_api_notify

    update_attributes(done: true, response: synchronizer.response.to_json)
    update_api_notify_log
  end

  def attributes_changed
    api_notifiable.fill_fields_with_values fields_updated
  end

  def update_api_notify_log
    log = api_notifiable.api_notify_logs.find_or_initialize_by(endpoint: endpoint)
    log.new_record? ? log.save : log.touch
  end
end
