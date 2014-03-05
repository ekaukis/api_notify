require "spec_helper"

describe ApiNotify::ActiveRecord::Main do

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
    FactoryGirl.create(:vehicle)
  end

  describe ".method_missing" do
    context "when affter_create triggered" do
      it "receivs post_via_api" do
        new_vehicle.should_receive(:post_via_api)
        new_vehicle.save!
      end
    end

    context "when affter_update triggered" do
      it "receivs post_via_api" do
        vehicle.should_receive(:post_via_api)
        vehicle.save!
      end
    end

    context "when affter_destroy triggered" do
      it "receivs delete_via_api" do
        vehicle.should_receive(:delete_via_api)
        vehicle.destroy
      end
    end

    context "when .skip_api_notify is true or sending params are empty" do
      it "skips sending data"
    end

    context "when successful response" do
      it "calls api_notify_(method)_success"
    end

    context "when responed with error" do
      it "calls api_notify_(method)_failed"
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

  it "should be defined .identificators "

  it "should be defined .notify_attributes"

  it "should be defined attr_accessor for #skip_api_notify"

  describe "self.route_name" do
    context "when api_route_name defined"  do
      it "uses #api_route_name for url"
    end

    context "when class_name defined" do
      it "uses #class_name for url"
    end

    context "when class_name not defined" do
      it "uses #name for url"
    end
  end

  describe "self.synchronized" do

  end

  describe ".attributes_as_params" do
    context "when is_synchronized defined" do
      context "and it is false" do
        it "send all fields"
      end

      context "and it is true" do
        it "send only chaned fields"
      end
    end

    context "when is_synchronized not defined" do
      it "sends only changed fields"
    end

    context "when changed _fields empty" do
      context "and method is post" do
        it "returns empty hash"
      end

      context "and method is delete" do
        it "returns hash with identificators"
      end
    end

    context "when changed fields not empty" do
      it "returns all fields"
    end
  end

end
