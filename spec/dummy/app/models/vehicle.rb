class Vehicle < ActiveRecord::Base

  belongs_to :dealer
  has_one :vehicle_type

  api_notify [
    :no,
    :vin,
    :make,
    :dealer_id,
    'dealer.title',
    'vehicle_type.title'
  ],
  {
    id: :id,
    one_dealer_id: "dealer.other_system_id"
  },
  {
    one: {
      skip_synchronize: :one_dont_do_synchronize,
    },
    other: {
      skip_synchronize: :other_dont_do_synchronize,
    }
  },
  api_route_name: "vehicles"

  before_save :other_dont

  attr_accessor :one_dont_do_synchronize, :other_dont_do_synchronize

  def other_dont
    self.other_dont_do_synchronize = true#unless dealer_id
  end

  def one_api_notify_post_success response
    update_columns(other: response[:body]["other"])
  end
end
