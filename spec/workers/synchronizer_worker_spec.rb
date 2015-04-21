require 'spec_helper'

describe ApiNotify::SynchronizerWorker do

  let(:dealer) do
    stub_request(:post, "https://one.example.com/api/v1/dealers").
      to_return(status: 201, body: '{ "other": "10" }')

    dealer = create(:dealer)
    described_class.drain
    dealer
  end

  it "pushes job into queue" do
    Sidekiq::Testing.fake!
    expect{ described_class.perform_async(dealer.api_notify_tasks.last.id) }.to change(described_class.jobs, :size).by(1)
  end

end
