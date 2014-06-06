module ApiNotify
  class SynchronizerWorker
    include Sidekiq::Worker


    def perform(id)
      task = Task.find(id)
      task.synchronize
    end
  end
end
