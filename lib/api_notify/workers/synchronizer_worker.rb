class SynchronizerWorker
  include Sidekiq::Worker

  def perform(task_id)
    puts "Do something"
  end
end
