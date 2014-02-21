class Dealer < ActiveRecord::Base

  attr_accessible :title

  has_many :vehicles

  api_notify [:title], { other_system_id: :id }, is_synchronized: :synchronized
end
