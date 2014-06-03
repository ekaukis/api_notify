require 'spec_helper'

describe VehicleType do
  describe "ActiveRecord associations" do
    it { expect(subject).to belong_to(:vehicle) }
  end
end
