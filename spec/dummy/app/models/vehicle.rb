class Vehicle < ActiveRecord::Base

  attr_accessible :no, :vin, :make, :dealer_id, :other

  belongs_to :dealer
  has_one :vehicle_type

  api_notify [:no, :vin, :make, :dealer_id, 'dealer.title', 'vehicle_type.title'], { id: :id }

  def api_notify_post_success response
    self.other = response[:body]["other"]
    self.save
  end
end
