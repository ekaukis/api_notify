require 'spec_helper'

describe ApiNotify::Task do
  describe "ActiveRecord associations" do
    it { expect(subject).to belong_to(:api_notifiable) }
  end

  describe "api_notifiable" do

    let(:dealer) do
      stub_request(:post, "https://one.example.com/api/v1/dealers")
      .to_return(
        status: 201,
        body: '{
          "other_system_id": "New 10"
        }',
        headers: {}
      ).times(1)

      FactoryGirl.create(:dealer_synchronized)
    end

    let(:vehicle) do
      stub_request(:post, "https://one.example.com/api/v1/vehicles")
      .to_return(
        status: 201,
        body: '{
          "other": "New info"
        }',
        headers: {}
      ).times(1)

      stub_request(:post, "http://other.example.com/api/v1/vehicles")
      .to_return(
        status: 201,
        body: '{
          "other": "New info"
        }',
        headers: {}
      ).times(1)


      FactoryGirl.build(:vehicle, dealer: dealer)
    end

    let(:subject) do
      vehicle.save
      vehicle.api_notify_tasks.last
    end

    context "when creates record" do
      it "sets method" do
        expect(subject.method).to eq("post")
      end

      it "sets fields_updated" do
        expect(subject.fields_updated).to eq([:no, :vin, :make, :dealer_id, "dealer.title", "vehicle_type.title"])
      end

      it "sets identificators" do
        expect(subject.identificators).to eq({id: vehicle.id})
      end

      it "sets endpoint" do
        expect(subject.endpoint).to eq("one")
      end

      it "sets api_notifiable" do
        expect(subject.api_notifiable).to eq(vehicle)
      end

      it "creates work for synchronization" do
        subject
        expect(ApiNotify::SynchronizerWorker.jobs.last["args"]).to eq([subject.id])
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

      it "sets response" do
        expect(subject.reload.response).to eq("{\"status\":\"201\",\"body\":{\"other\":\"New info\"}}")
      end

      it "sends request to endpoint" do
        body = "dealer.title=#{dealer.title}&" +
               "dealer_id=#{dealer.id}&" +
               "id=#{vehicle.id}&" +
               "make=#{vehicle.make}&" +
               "no=#{vehicle.no}&" +
               "vehicle_type.title=#{vehicle.vehicle_type.title}&" +
               "vin=#{vehicle.vin}"

        expect(a_request(:post, "https://one.example.com/api/v1/vehicles").with { |req| req.body == body }).
          to have_been_made
      end

      it "creates api_notify_log records" do
        expect(vehicle.api_notify_logs.size).to eq(1)
      end

    end

  end

  describe ".synchronize" do
    before {Sidekiq::Testing.inline!}
    context "when error received" do
      it "raise error" do
        expect{FactoryGirl.create(:dealer)}.to raise_error(ApiNotify::SynchronizerWorker::FailedSynchronization)
      end
    end
  end

end
