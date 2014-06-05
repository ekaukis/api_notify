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
  skip_synchronize: :dont_do_synchronize,
  endpoints: [
    {
      name: :one,
      skip_syncronize: :dont_do_synchronize,
      is_synchronized: :synchronized
    },
    {
      name: :other,
      skip_syncronize: :dont_do_synchronize,
      is_synchronized: :synchronized
    }
  ]

  attr_accessor :dont_do_synchronize

  def api_notify_post_success response
    self.other = response[:body]["other"]
    self.save
  end
end
