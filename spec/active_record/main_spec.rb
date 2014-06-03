require "spec_helper"

describe ApiNotify::ActiveRecord::Main do

  let(:dealer) { FactoryGirl.create(:dealer_synchronized) }
  let(:new_vehicle){ Vehicle.new(dealer_id: dealer.id) }
  let(:vehicle) do
    # stub_request(:post, "https://example.com/api/v1/vehicles")
    # .to_return(
    #   status: 201,
    #   body: '{
    #     "other": "New info"
    #   }',
    #   headers: {}
    # )
    FactoryGirl.create(:vehicle, dealer_id: dealer.id)
  end

  describe ".method_missing" do
    context "when affter_create triggered" do
      it "receivs post_via_api" do
        expect(new_vehicle).to receive(:post_via_api)
        new_vehicle.save!
      end
    end

    context "when affter_update triggered" do
      it "receivs post_via_api" do
        expect(vehicle).to receive(:post_via_api)
        vehicle.save!
      end
    end

    context "when affter_destroy triggered" do
      it "receivs delete_via_api" do
        expect(vehicle).to receive(:delete_via_api)
        vehicle.destroy
      end
    end

    context "when :post_via_api" do
      it "returns true", pending: "must be false but is true" do
        vehicle.dealer_id = nil
        expect(vehicle.post_via_api).to be_false
      end
    end
  end

  describe ".save_without_api_notify" do
    it "saves without triggering api" do
      vehicle.make = "VOLVO"
      vehicle.save_without_api_notify
      expect(vehicle.make).to eq("VOLVO")
    end
  end

  describe ".update_attributes_without_api_notify" do
    it "updates attributes without triggering api" do
      vehicle.update_attributes_without_api_notify make: "VOLVO"
      expect(vehicle.make).to eq("VOLVO")
    end
  end

  describe ".attributes_as_params" do
    context "when changed field value is nil" do
      it "return attributes with empty value" do
        vehicle.dealer_id = nil
        expect(vehicle.attributes_as_params).to eq({:dealer_id=>nil})
      end
    end

    context "when changed field value is not present" do
      it "return attributes with empty value" do
        vehicle.dealer_id = ""
        expect(vehicle.attributes_as_params).to eq({:dealer_id=>nil})
      end
    end

    context "when changed field value is present" do
      it "returns normal params " do
        dealer = FactoryGirl.create(:dealer_synchronized)
        vehicle.dealer_id = dealer.id
        expect(vehicle.attributes_as_params).to eq({:dealer_id=>dealer.id})
      end
    end
  end

  describe ".no_need_to_synchronize?" do
    let(:vehicle) { FactoryGirl.create(:vehicle) }
    let(:dealer) { FactoryGirl.create(:dealer_synchronized) }

    context "when skip_synchronize is true" do
      it "returns true" do
        vehicle.vin = "2131232"
        vehicle.set_attributes_changed
        vehicle.dont_do_synchronize = true
        expect(vehicle.no_need_to_synchronize?('post')).to eq(true)
      end
    end

    context "when skip_synchronize is false" do
      context "and attributes changed not empty" do
        it "returns false" do
          vehicle.vin = "2131232"
          vehicle.set_attributes_changed
          vehicle.dont_do_synchronize = false
          expect(vehicle.no_need_to_synchronize?('post')).to eq(false)
        end
      end

      context "and attributes changed is empty with method delete" do
        it "returns false" do
          vehicle.set_attributes_changed
          vehicle.dont_do_synchronize = false
          expect(vehicle.no_need_to_synchronize?('delete')).to eq(false)
        end
      end

      context "and attributes changed is empty with other method" do
        it "returns true" do
          vehicle.set_attributes_changed
          vehicle.dont_do_synchronize = false
          expect(vehicle.no_need_to_synchronize?('post')).to eq(true)
        end
      end
    end

    context "when skip_synchronize not defined" do
      context "and attributes changed not empty" do
        it "returns false" do
          dealer.title = "DDT"
          dealer.set_attributes_changed
          expect(dealer.no_need_to_synchronize?('post')).to eq(false)
        end
      end

      context "and attributes changed is empty with method delete" do
        it "returns false" do
          dealer.set_attributes_changed
          expect(dealer.no_need_to_synchronize?('delete')).to eq(false)
        end
      end

      context "and attributes changed is empty with other method" do
        it "return true" do
          dealer.set_attributes_changed
          expect(dealer.no_need_to_synchronize?('post')).to eq(true)
        end
      end
    end

    context "when must synch is true" do
      it "returns false" do
        dealer.synchronized = false
        dealer.set_attributes_changed
        expect(dealer.no_need_to_synchronize?('post')).to eq(false)
      end
    end

  end

end
