require 'spec_helper'

describe Vehicle do
  let(:dealer) { FactoryGirl.create(:dealer_synchronized) }
  let(:vehicle_type) {FactoryGirl.build(:vehicle_type)}
  let(:vehicle) do
    stub_request(:post, "https://example.com/api/v1/vehicles")
    .to_return(
      status: 201,
      body: '{
        "other": "New info"
      }',
      headers: {}
    ).times(1)
    FactoryGirl.create(:vehicle, make: "AUDI", dealer_id: dealer.id)
  end

  context "when initialize vehicle" do
    it "creates vehicle" do
      expect(vehicle.other).to eq("New info")
    end

    it "updates sales_price" do
      stub_request(:post, "https://example.com/api/v1/vehicles"
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

    context "when dealer_title changed" do
      before do
        stub_request(:post, "https://example.com/api/v1/vehicles"
          ).to_return(
            status: 201,
            body: '{
              "dealer_id": "12"
            }',
            headers: {}
          )

        vehicle.dealer.title = "Dealer title"
        vehicle.save
      end

      it "updates dealer_title" do
        expect(vehicle.dealer.title).to eq("Dealer title")
      end

      it "sends request" do
        a_request(:any, "https://example.com/api/v1/vehicles").should have_been_made.times(2)
      end
    end

    context "when vehicle_type changed" do
      before do
        stub_request(:post, "https://example.com/api/v1/vehicles"
          ).to_return(
            status: 201,
            body: '{
              "dealer_id": "12"
            }',
            headers: {}
          )

        vehicle.vehicle_type.title = "Vehicle title"
        vehicle.save
      end

      it "updates dealer_title" do
        expect(vehicle.vehicle_type.title).to eq("Vehicle title")
      end

      it "sends request" do
        a_request(:any, "https://example.com/api/v1/vehicles").should have_been_made.times(2)
      end
    end

    it "destroys vehicle" do
      stub_request(:delete, "https://example.com/api/v1/vehicles/#{vehicle.id}"
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
