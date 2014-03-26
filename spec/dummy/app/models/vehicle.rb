class Vehicle < ActiveRecord::Base

  attr_accessible :no, :vin, :make, :dealer_id, :other

  belongs_to :dealer

  api_notify [:no, :vin, :make, :dealer_id], { id: :id }

  def api_notify_post_success response
    self.other = response[:body]["other"]
    self.save
  end
end
