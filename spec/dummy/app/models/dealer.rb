class Dealer < ActiveRecord::Base

  has_many :vehicles

  api_notify [
    :title
    ],
    {
      other_system_id: :id
    },
    endpoints: [
      :dealer

    ]
end
