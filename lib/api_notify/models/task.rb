module ApiNotify
  class Task < ActiveRecord::Base

    self.table_name = :api_notify_tasks

    belongs_to :api_notifiable, polymorphic: true

    serialize :fields_updated, Array
    serialize :identificators, Hash

    before_validation :make_changes_hash, on: :create
    validates :changes_hash, uniqueness: {scope: :done, unless: :done}
    after_commit :setup_task, on: :create

    def make_changes_hash
      self.changes_hash =
        Digest::MD5.new.hexdigest(
          [
            api_notifiable_id,
            api_notifiable_type,
            fields_updated.to_s,
            created_at.to_s,
            endpoint,
            method
          ].join
        )
    end

    def synchronizer
      @synchronizer ||=
        api_notifiable_type.constantize.synchronizer
    end

    def synchronize
      synchronizer.set_params(attributes)
      synchronizer.send_request(method.upcase, false, endpoint)

      send_callback unless method == "delete"

      update!(
        done: synchronizer.success?,
        response: synchronizer.response.to_json
      )
    rescue ApiNotify::ActiveRecord::Synchronizer::FailedSynchronization => e
      LOGGER.info("Exception raised: #{ e.message }")
    end

    def send_callback
      api_notifiable.without_api_notify do
        if synchronizer.success?
          if remote_destroyed?(synchronizer.response)
            api_notifiable.remove_api_notified(endpoint)
            api_notifiable.remove_api_notified_children(endpoint)
          else
            api_notifiable.make_api_notified(endpoint)
            api_notifiable.send(
              "#{ endpoint }_api_notify_#{ method }_success",
              synchronizer.response
            )
            api_notifiable.notify_children(endpoint)
          end
        else
          api_notifiable.send(
            "#{ endpoint }_api_notify_#{ method }_failed",
            synchronizer.response
          )
        end
      end
    end

    def attributes
      (identificators.merge(api_notifiable.fill_fields_with_values(fields_updated)) if api_notifiable) || identificators
    end

    def setup_task
      LOGGER.info "TASK CREATED #{api_notifiable_type} #{api_notifiable_id}"
      SynchronizerWorker.perform_async(id)
    end

    def remote_destroyed?(response)
      response[:body].try(:[], "api_notify_destroyed") ? true : false
    end
  end
end
