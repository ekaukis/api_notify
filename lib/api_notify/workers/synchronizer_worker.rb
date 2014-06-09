module ApiNotify
  class SynchronizerWorker
    include Sidekiq::Worker
    sidekiq_options :retry => 5

    class FailedSynchronization < StandardError; end

    def perform(id)
      task = Task.find(id)
      task.synchronize
      raise FailedSynchronization, task.response unless task.done
    end
  end
end
