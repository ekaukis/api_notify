require "spec_helper"

describe ApiNotify::Configuration do
  let(:new_vehicle){ Vehicle.new }
  let(:vehicle) do
    stub_request(:post, "https://one.example.com/api/v1/dealers")
      .to_return(status: 201, body: '{"other": "New info"}', headers: {})

    stub_request(:post, "https://one.example.com/api/v1/vehicles")
      .to_return(status: 201, body: '{"other": "New info"}', headers: {})

    FactoryGirl.build(:vehicle)
  end

  context "when api_notify active" do
    it "receivs post_via_api" do
      Sidekiq::Testing.inline!
      vehicle.save
      expect(a_request(:post, "https://one.example.com/api/v1/vehicles")).to have_been_made
    end
  end

  context "when api_notify disabled" do
    before do
      allow(ApiNotify.configuration).to receive(:active).and_return(false)
      allow(ApiNotify.configuration).to receive(:config_file).and_return(false)
    end

    it "doesn't receivs post_via_api" do
      vehicle.save
      expect(a_request(:post, "https://one.example.com/api/v1/vehicles")).to have_not_been_made
    end
  end

  describe ".endpoint_active?" do
    context "when config_hash nil" do
      it "return false" do
        allow(ApiNotify.configuration).to receive(:config_defined?).and_return(false)
        expect(ApiNotify.configuration.endpoint_active?(:one)).to be_falsey
      end
    end

    context "when config_hash with endpoint one" do
      it "return true" do
        expect(ApiNotify.configuration.endpoint_active?(:one)).to be_truthy
      end
    end
  end


end
