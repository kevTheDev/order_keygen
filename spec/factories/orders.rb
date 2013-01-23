FactoryGirl.define do
  factory :order do
    sequence(:shopify_id) { |n| "ID_#{n}" }
  end
end