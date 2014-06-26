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
      identificators: {
        one_dealer_id: "dealer.other_system_id"
      },
      skip_synchronize: :one_dont_do_synchronize,
      parent_attribute: :one_dealer_id,
      scope: :one_unsynchronized_scope
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

  class << self
    def one_unsynchronized_scope
      where("vehicles.dealer_id > 0")
    end
  end

end
