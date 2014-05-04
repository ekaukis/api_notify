class Dealer < ActiveRecord::Base

  has_many :vehicles

  api_notify [:title], { other_system_id: :id }, is_synchronized: :synchronized
end
