require "spec_helper"

describe ApiNotify::ActiveRecord::Synchronizer do
  # let(:new_vehicle){ Vehicle.new }
  # let(:vehicle) do
  #   stub_request(:post, "https://example.com/api/v1/vehicles").
  #     to_return( status: 201, body: '{ "other": "New info" }', headers: {} )
  #   FactoryGirl.create(:vehicle)
  # end
  #
  # let(:vehicle_error) do
  #   stub_request(:post, "https://example.com/api/v1/vehicles").
  #     to_return( status: 400, body: '{ "other": "New info" }', headers: {} )
  #   FactoryGirl.create(:vehicle)
  # end
  #
  # let(:vehicle_failed) do
  #   stub_request(:post, "https://example.com/api/v1/vehicles").
  #     to_raise(StandardError)
  #   FactoryGirl.create(:vehicle)
  # end
  #
  # let(:vehicle_syntax) do
  #   stub_request(:post, "https://example.com/api/v1/vehicles").
  #     to_return( status: 400, body: '{ other: "New info" }', headers: {} )
  #   FactoryGirl.create(:vehicle)
  # end

  describe ".initialize" do

  end

  describe ".response" do
    # let(:synchronizer){ ApiNotify::ActiveRecord::Synchronizer.new('vehicles', :id) }
    # context "when status 201" do
    #
    #   it "responds full message" do
    #     stub_request(:post, "https://example.com/api/v1/vehicles").
    #       to_return( status: 201, body: '{ "other": "New info" }', headers: {} )
    #
    #     synchronizer.send_request('POST')
    #     expect(synchronizer.response).to eq({:status=>"201", :body=>{"other"=>"New info"}})
    #   end
    #
    #   context "when response without code" do
    #     it "responds with error" do
    #       synchronizer.send_request('POST')
    #       expect(synchronizer.response[:status]).to eq("NoMethodError")
    #     end
    #   end
    #
    #   context "and body isn't json" do
    #     it "responds with error" do
    #       stub_request(:post, "https://example.com/api/v1/vehicles").
    #         to_return( status: 201, body: 'hello', headers: {} )
    #
    #       synchronizer.send_request('POST')
    #       expect(synchronizer.response[:body]).to eq("757: unexpected token at 'hello' | hello")
    #     end
    #   end

    #end

    context "when responded with internal server error" do

    end

    context "when responded with error" do

    end



  end

  describe ".success?" do

  end

  describe ".send_request" do

  end

  describe ".url" do

  end
end
