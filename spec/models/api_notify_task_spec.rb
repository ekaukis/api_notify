require 'spec_helper'

describe ApiNotifyTask do
  describe "ActiveRecord associations" do
    it { expect(subject).to belong_to(:api_notifiable) }
  end

  describe "api_notifiable" do

    let(:dealer) { FactoryGirl.create(:dealer_synchronized) }
    let(:vehicle) { FactoryGirl.build(:vehicle, dealer: dealer) }

    let(:subject) do
      vehicle.save
      vehicle.api_notify_tasks.last
    end

    context "when creates record" do
      it "sets method" do
        expect(subject.method).to eq("post")
      end

      it "sets fields_updated" do
        expect(subject.fields_updated).to eq([:no, :vin, :make, :dealer_id])
      end

      it "sets endpoint" do
        expect(subject.endpoint).to eq("dealer")
      end

      it "sets api_notifiable" do
        expect(subject.api_notifiable).to eq(vehicle)
      end

      it "creates work for synchronization" do
        subject
        expect(ApiNotify::Workers::SynchronizerWorker.jobs.last["args"]).to eq([subject.id])
      end
    end

    context "when perform task" do
      before do
        Sidekiq::Testing.inline!
        subject
      end

      it "changes done to true" do
        expect(subject.done).to be_truthy
      end

      it "sends request to endpoint" do
        # stub_request(:post, "https://example.com/api/v1/vehicles")
        # .to_return(
        #   status: 201,
        #   body: '{
        #     "other": "New info"
        #   }',
        #   headers: {}
        # ).times(1)

        expect(a_request(:post, "https://one.example.com/api/v1/vehicles")).to have_been_made
        #expect(subject.done).to be_truthy
      end

      it "updates rubie_id to api_notifiable"

    end

  end

end
