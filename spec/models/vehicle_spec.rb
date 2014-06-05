require 'spec_helper'

describe Vehicle do

  it_behaves_like "an Api Notified includer"

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
        expect(subject.fields_changed).to eq([:no, :vin, :make, :dealer_id])
      end
    end

    describe "#via_api" do
      it "creates api_notify_task" do
        expect{subject.save}.to change{ApiNotifyTask.all.size}.from(0).to(2)
      end
    end
  end
#
#
#   context "when :post_via_api" do
#     it "returns true", pending: "must be false but is true" do
#       vehicle.dealer_id = nil
#       expect(vehicle.post_via_api).to be_false
#     end
#   end
#
#
#   describe ".save_without_api_notify" do
#     it "saves without triggering api" do
#       vehicle.make = "VOLVO"
#       vehicle.save_without_api_notify
#       expect(vehicle.make).to eq("VOLVO")
#     end
#   end
#
#   describe ".update_attributes_without_api_notify" do
#     it "updates attributes without triggering api" do
#       vehicle.update_attributes_without_api_notify make: "VOLVO"
#       expect(vehicle.make).to eq("VOLVO")
#     end
#   end
#
#   describe ".attributes_as_params" do
#     context "when changed field value is nil" do
#       it "return attributes with empty value" do
#         vehicle.dealer_id = nil
#         expect(vehicle.attributes_as_params).to eq({:dealer_id=>nil})
#       end
#     end
#
#     context "when changed field value is not present" do
#       it "return attributes with empty value" do
#         vehicle.dealer_id = ""
#         expect(vehicle.attributes_as_params).to eq({:dealer_id=>nil})
#       end
#     end
#
#     context "when changed field value is present" do
#       it "returns normal params " do
#         dealer = FactoryGirl.create(:dealer_synchronized)
#         vehicle.dealer_id = dealer.id
#         expect(vehicle.attributes_as_params).to eq({:dealer_id=>dealer.id})
#       end
#     end
#   end
#
#   describe ".no_need_to_synchronize?" do
#     let(:vehicle) { FactoryGirl.create(:vehicle) }
#     let(:dealer) { FactoryGirl.create(:dealer_synchronized) }
#
#     context "when skip_synchronize is true" do
#       it "returns true" do
#         vehicle.vin = "2131232"
#         vehicle.set_attributes_changed
#         vehicle.dont_do_synchronize = true
#         expect(vehicle.no_need_to_synchronize?('post')).to eq(true)
#       end
#     end
#
#     context "when skip_synchronize is false" do
#       context "and attributes changed not empty" do
#         it "returns false" do
#           vehicle.vin = "2131232"
#           vehicle.set_attributes_changed
#           vehicle.dont_do_synchronize = false
#           expect(vehicle.no_need_to_synchronize?('post')).to eq(false)
#         end
#       end
#
#       context "and attributes changed is empty with method delete" do
#         it "returns false" do
#           vehicle.set_attributes_changed
#           vehicle.dont_do_synchronize = false
#           expect(vehicle.no_need_to_synchronize?('delete')).to eq(false)
#         end
#       end
#
#       context "and attributes changed is empty with other method" do
#         it "returns true" do
#           vehicle.set_attributes_changed
#           vehicle.dont_do_synchronize = false
#           expect(vehicle.no_need_to_synchronize?('post')).to eq(true)
#         end
#       end
#     end
#
#     context "when skip_synchronize not defined" do
#       context "and attributes changed not empty" do
#         it "returns false" do
#           dealer.title = "DDT"
#           dealer.set_attributes_changed
#           expect(dealer.no_need_to_synchronize?('post')).to eq(false)
#         end
#       end
#
#       context "and attributes changed is empty with method delete" do
#         it "returns false" do
#           dealer.set_attributes_changed
#           expect(dealer.no_need_to_synchronize?('delete')).to eq(false)
#         end
#       end
#
#       context "and attributes changed is empty with other method" do
#         it "return true" do
#           dealer.set_attributes_changed
#           expect(dealer.no_need_to_synchronize?('post')).to eq(true)
#         end
#       end
#     end
#
#     context "when must synch is true" do
#       it "returns false" do
#         dealer.synchronized = false
#         dealer.set_attributes_changed
#         expect(dealer.no_need_to_synchronize?('post')).to eq(false)
#       end
#     end
#
#   end


  # let(:dealer) { FactoryGirl.create(:dealer_synchronized) }
#   let(:vehicle_type) {FactoryGirl.build(:vehicle_type)}
#   let(:subject) do
#     stub_request(:post, "https://example.com/api/v1/vehicles")
#     .to_return(
#       status: 201,
#       body: '{
#         "other": "New info"
#       }',
#       headers: {}
#     ).times(1)
#     FactoryGirl.create(:subject, make: "AUDI", dealer_id: dealer.id)
#   end
#
#   context "when initialize vehicle" do
#     it "creates vehicle" do
#       expect(vehicle.other).to eq("New info")
#     end
#
#     it "updates sales_price" do
#       stub_request(:post, "https://example.com/api/v1/vehicles"
#         ).to_return(
#           status: 201,
#           body: '{
#             "dealer_id": "12"
#           }',
#           headers: {}
#         )
#
#       vehicle.no = "HPPP"
#       vehicle.save
#       expect(vehicle.no).to eq("HPPP")
#     end
#
#     context "when dealer_title changed" do
#       before do
#         stub_request(:post, "https://example.com/api/v1/vehicles"
#           ).to_return(
#             status: 201,
#             body: '{
#               "dealer_id": "12"
#             }',
#             headers: {}
#           )
#
#         vehicle.dealer.title = "Dealer title"
#         vehicle.save
#       end
#
#       it "updates dealer_title" do
#         expect(vehicle.dealer.title).to eq("Dealer title")
#       end
#
#       it "sends request" do
#         expect(a_request(:any, "https://example.com/api/v1/vehicles")).to have_been_made.times(2)
#       end
#     end
#
#     context "when vehicle_type changed" do
#       before do
#         stub_request(:post, "https://example.com/api/v1/vehicles"
#           ).to_return(
#             status: 201,
#             body: '{
#               "dealer_id": "12"
#             }',
#             headers: {}
#           )
#
#         vehicle.vehicle_type.title = "Vehicle title"
#         vehicle.save
#       end
#
#       it "updates dealer_title" do
#         expect(vehicle.vehicle_type.title).to eq("Vehicle title")
#       end
#
#       it "sends request" do
#         expect(a_request(:any, "https://example.com/api/v1/vehicles")).to have_been_made.times(2)
#       end
#     end
#
#     it "destroys vehicle" do
#       stub_request(:delete, "https://example.com/api/v1/vehicles/#{vehicle.id}"
#         ).to_return(
#           status: 204,
#           body: '{
#             "dealer_id": "12"
#           }',
#           headers: {}
#         )
#       vehicle.destroy
#     end
#   end

end
