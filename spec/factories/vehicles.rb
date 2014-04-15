FactoryGirl.define do

  factory :vehicle do
    no "HP2323"
    vin "123232323"
    make "VW"
    association :dealer, :factory => :dealer_synchronized
    other "some other field"
    association :vehicle_type, :factory => :vehicle_type
  end

end
