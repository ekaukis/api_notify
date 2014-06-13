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
      skip_synchronize: :dont_do_synchronize
    }
  },
  children: [Vehicle]

  attr_accessor :dont_do_synchronize

  def one_api_notify_post_success response
    update_columns(other_system_id: response[:body]["id"])
  end
end
