require 'spec_helper'

describe Vehicle do
  let(:vehicle) do
    stub_request(:post, "http://example.com/api/v1/vehicles")
    .to_return(
      status: 201,
      body: '{
        "other": "New info"
      }',
      headers: {}
    )
    FactoryGirl.create(:vehicle, make: "AUDI", dealer_id: nil)
  end

  context "when initialize vehicle" do
    it "creates vehicle" do
      expect(vehicle.other).to eq("New info")
    end

    it "updates sales_price" do
      stub_request(:post, "http://example.com/api/v1/vehicles/#{vehicle.id}"
        ).to_return(
          status: 201,
          body: '{
            "dealer_id": "12"
          }',
          headers: {}
        )

      vehicle.no = "HPPP"
      vehicle.save
      expect(vehicle.no).to eq("HPPP")
    end

    it "destroys vehicle" do
      stub_request(:delete, "http://example.com/api/v1/vehicles/#{vehicle.id}"
        ).to_return(
          status: 204,
          body: '{
            "dealer_id": "12"
          }',
          headers: {}
        )
      vehicle.destroy
    end
  end

end
