module ApiNotify
  module Workers
    class SynchronizerWorker
      include Sidekiq::Worker


      def perform(id)
        task = ApiNotifyTask.find(id)
        task.synchronize
      end
    end
  end
end
