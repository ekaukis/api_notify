# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :vehicle_type do
    title "Easy"
    category "Peasy"
    vehicle nil
  end
end
