require 'spec_helper'

describe Dealer do
  it_behaves_like "an Api Notified includer"

  describe "ActiveRecord associations" do
    it { expect(subject).to have_many(:vehicles) }
  end

  describe "#children_synchronization" do
    it "synchronizes all child elements" do
      Sidekiq::Testing.fake!

      stub_request(:post, "https://one.example.com/api/v1/dealers").
        to_return( status: 201, body: '{ "id": "1" }', headers: {} )

      stub_request(:post, "https://one.example.com/api/v1/vehicles").
        to_return( status: 201, body: '{ "other": "New info" }', headers: {} )

      vehicle = FactoryGirl.create(:vehicle)
      ApiNotify::SynchronizerWorker.drain
      vehicle.remove_api_notified(:one)

      dealer = FactoryGirl.build(:dealer)
      dealer.vehicles.build FactoryGirl.attributes_for(:vehicle)
      dealer.save

      ApiNotify::SynchronizerWorker.drain

      expect(dealer.api_notified?(:one)).to be_truthy
      expect(dealer.vehicles.first.api_notified?(:one)).to be_truthy
      expect(vehicle.api_notified?(:one)).to be_falsey
    end
  end
end
