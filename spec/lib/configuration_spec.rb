require "spec_helper"

describe ApiNotify::Configuration do
  let(:new_vehicle){ Vehicle.new }
  let(:vehicle) do
    stub_request(:post, "https://example.com/api/v1/vehicles")
    .to_return(
      status: 201,
      body: '{
        "other": "New info"
      }',
      headers: {}
    )
    FactoryGirl.build(:vehicle)
  end

  context "when api_notify active" do
    it "receivs post_via_api" do
      vehicle.save
      a_request(:post, "https://example.com/api/v1/vehicles").should have_been_made
    end
  end

  context "when api_notify disabled" do
    before do
      ApiNotify.configuration.stub("active").and_return(false)
      ApiNotify.configuration.stub("config_file").and_return(false)
    end

    it "doesn't receivs post_via_api" do
      vehicle.save
      a_request(:post, "https://example.com/api/v1/vehicles").should_not have_been_made
    end
  end
end
