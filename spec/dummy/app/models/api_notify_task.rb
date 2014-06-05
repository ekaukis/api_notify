class ApiNotifyTask < ActiveRecord::Base
  belongs_to :api_notifiable, polymorphic: true

  serialize :fields_updated

  def synchronize
    synchronizer = api_notifiable.class.synchronizer
    synchronizer.set_params(attributes_changed.merge(api_notifiable.get_identificators))
    synchronizer.send_request(method.upcase, endpoint)

    api_notifiable.disable_api_notify

    if synchronizer.success?
      api_notifiable.send("api_notify_#{method}_success", synchronizer.response)
    else
      api_notifiable.send("api_notify_#{method}_failed", synchronizer.response)
    end

    api_notifiable.enable_api_notify

    update_attribute(:done, true)
  end

  def attributes_changed
    {no: "1212"}
  end
end
