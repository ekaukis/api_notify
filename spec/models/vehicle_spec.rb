require 'spec_helper'

describe Vehicle do

  it_behaves_like "an Api Notified includer"

  let(:vehicle) do
    stub_request(:post, "https://one.example.com/api/v1/vehicles")
      .to_return( status: 201, body: '{ "other": "New info" }', headers: {} )

    FactoryGirl.create(:vehicle, dealer: dealer)
  end

  let(:dealer) do
    stub_request(:post, "https://one.example.com/api/v1/dealers")
      .to_return( status: 201, body: '{ "other_system_id": "10" }', headers: {} )

    FactoryGirl.create(:dealer_synchronized)
  end

  describe "ActiveRecord associations" do
    it { expect(subject).to have_one(:vehicle_type) }
    it { expect(subject).to belong_to(:dealer) }
  end

  describe "#api_notify methods" do
    let(:dealer) { FactoryGirl.create(:dealer_synchronized) }
    let(:subject) { FactoryGirl.build(:vehicle, dealer: dealer) }

    describe ".set_fields_changed" do
      it "sets fields_changed" do
        subject.set_fields_changed
        expect(subject.fields_changed(:one)).to eq([:no, :vin, :make, :dealer_id, "dealer.title", "vehicle_type.title"])
        expect(subject.fields_changed(:other)).to eq([:no, :vin, :make, :dealer_id, "dealer.title", "vehicle_type.title"])
      end
    end

    describe "#via_api" do
      it "creates api_notify_task" do
        expect{subject.save}.to change{ApiNotify::Task.all.size}.from(0).to(2)
      end
    end
  end

  describe ".no_need_to_synchronize?" do
    before do
      Sidekiq::Testing.inline!
    end

    context "when skip_synchronize is true" do
      it "returns true" do
        vehicle.vin = "2131232"
        vehicle.set_fields_changed
        vehicle.one_dont_do_synchronize = true
        expect(vehicle.no_need_to_synchronize?('post', :one)).to eq(true)
      end
    end

    context "when skip_synchronize is false" do
      context "and attributes changed not empty" do
        it "returns false" do
          vehicle.vin = "2131232"
          vehicle.set_fields_changed
          vehicle.one_dont_do_synchronize = false
          expect(vehicle.no_need_to_synchronize?('post', :one)).to eq(false)
        end
      end

      context "and attributes changed is empty with method delete" do
        it "returns false" do
          vehicle.set_fields_changed
          vehicle.one_dont_do_synchronize = false
          expect(vehicle.no_need_to_synchronize?('delete', :one)).to eq(false)
        end
      end

      context "and attributes changed is empty with other method" do
        it "returns true" do
          vehicle.set_fields_changed
          vehicle.one_dont_do_synchronize = false
          expect(vehicle.no_need_to_synchronize?('post', :one)).to eq(true)
        end
      end
    end

    context "when skip_synchronize not defined" do
      context "and attributes changed not empty" do
        it "returns false" do
          dealer.title = "DDT"
          dealer.set_fields_changed
          expect(dealer.no_need_to_synchronize?('post', :one)).to eq(false)
        end
      end

      context "and attributes changed is empty with method delete" do
        it "returns false" do
          dealer.set_fields_changed
          expect(dealer.no_need_to_synchronize?('delete', :one)).to eq(false)
        end
      end

      context "and attributes changed is empty with other method" do
        it "return true" do
          dealer.set_fields_changed
          expect(dealer.no_need_to_synchronize?('post', :one)).to eq(true)
        end
      end
    end

    context "when record not synchronized" do
      it "returns false" do
        dealer.api_notify_logs.first.destroy
        dealer.set_fields_changed
        expect(dealer.no_need_to_synchronize?('post', :one)).to eq(false)
      end
    end
  end

  describe ".save_without_api_notify" do
    it "saves without triggering api" do
      Sidekiq::Testing.inline!
      vehicle.make = "VOLVO"
      Sidekiq::Testing.fake!
      vehicle.save_without_api_notify
      expect(vehicle.make).to eq("VOLVO")
      expect(ApiNotify::SynchronizerWorker.jobs.size).to eq(0)
    end
  end

  describe ".update_attributes_without_api_notify" do
    it "updates attributes without triggering api" do
      Sidekiq::Testing.inline!
      vehicle
      Sidekiq::Testing.fake!
      vehicle.update_attributes_without_api_notify make: "VOLVO"
      expect(vehicle.make).to eq("VOLVO")
      expect(ApiNotify::SynchronizerWorker.jobs.size).to eq(0)
    end
  end

  describe ".destroy_without_api_notify" do
    it "destroys triggering api" do
      Sidekiq::Testing.inline!
      vehicle
      Sidekiq::Testing.fake!

      expect{vehicle.destroy_without_api_notify}.to change{Vehicle.all.size}.from(1).to(0)
      expect(ApiNotify::SynchronizerWorker.jobs.size).to eq(0)
    end
  end

  describe ".attributes_as_params" do
    before do
      Sidekiq::Testing.inline!
    end

    context "when changed field value is nil" do
      it "return attributes with empty value" do
        vehicle.dealer_id = nil
        expect(vehicle.fill_fields_with_values(vehicle.set_fields_changed[:one])).to eq({:dealer_id=>nil})
      end
    end

    context "when changed field value is not present" do
      it "return attributes with empty value" do
        vehicle.dealer_id = ""
        expect(vehicle.fill_fields_with_values(vehicle.set_fields_changed[:one])).to eq({:dealer_id=>nil})
      end
    end

    context "when changed field value is present" do
      it "returns normal params " do
        stub_request(:post, "https://one.example.com/api/v1/dealers")
          .to_return( status: 201, body: '{ "other_system_id": "10" }', headers: {} )

        dealer = FactoryGirl.create(:dealer_synchronized)
        vehicle.dealer_id = dealer.id
        expect(vehicle.fill_fields_with_values(vehicle.set_fields_changed[:one])).to eq({:dealer_id=>dealer.id})
      end
    end
  end

  context "when initialize vehicle" do
    before do
      Sidekiq::Testing.inline!
    end

    it "creates vehicle" do
      expect(vehicle.reload.other).to eq("New info")
    end

    it "updates sales_price" do
      stub_request(:post, "https://one.example.com/api/v1/vehicles"
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
        stub_request(:post, "https://one.example.com/api/v1/vehicles"
          ).to_return( status: 201, body: '{ "dealer_id": "12" }', headers: {} )

        vehicle.dealer.dont_do_synchronize = true
        vehicle.dealer.title = "Dealer title"
        vehicle.save
      end

      it "updates dealer_title" do
        expect(vehicle.dealer.title).to eq("Dealer title")
      end

      it "sends request" do
        expect(a_request(:any, "https://one.example.com/api/v1/vehicles")).to have_been_made.times(2)
      end
    end

    context "when vehicle_type changed" do
      before do
        stub_request(:post, "https://one.example.com/api/v1/vehicles"
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
        expect(a_request(:any, "https://one.example.com/api/v1/vehicles")).to have_been_made.times(2)
      end
    end

    it "destroys vehicle" do
      stub_request(:delete, "https://one.example.com/api/v1/vehicles/#{vehicle.id}"
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
