FactoryGirl.define do

  factory :dealer do
    synchronized false
    other_system_id nil

    factory :dealer_synchronized do
      synchronized true
      other_system_id 1
    end
  end

end
