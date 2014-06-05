class Dealer < ActiveRecord::Base

  has_many :vehicles

  api_notify [
    :title
  ],
  {
    other_system_id: :id
  },
  {
    one: {
      #skip_synchronize: :dont_do_synchronize
    }
  }

end
