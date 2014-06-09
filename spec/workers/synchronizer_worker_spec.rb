require 'spec_helper'

describe ApiNotify::SynchronizerWorker do

  let(:vehicle) do
    stub_request(:post, "https://one.example.com/api/v1/vehicles").
      to_return(status: 201, body: '{ "other": "10" }')

    FactoryGirl.create(:vehicle)
  end

  it "pushes job into queue" do
    Sidekiq::Testing.fake!
    expect{ described_class.perform_async(vehicle.api_notify_tasks.last.id) }.to change(described_class.jobs, :size).by(3)
  end

end
