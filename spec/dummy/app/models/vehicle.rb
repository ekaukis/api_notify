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
    id: :id
  },
  {
    one: {
      skip_synchronize: :one_dont_do_synchronize,
    },
    other: {
      skip_synchronize: :other_dont_do_synchronize,
    }
  },
  route_name: "the_vehicles"

  attr_accessor :one_dont_do_synchronize, :other_dont_do_synchronize

  def api_notify_post_success response
    update_columns(other: response[:body]["other"])
  end
end
