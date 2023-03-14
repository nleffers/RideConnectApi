FactoryBot.define do
  factory :ride do
    sequence(:start_address) { |n| "#{n} Fake St" }
    sequence(:start_city, 'A') { |n| "#{n} City" }
    sequence(:start_state, 'A') { |n| "#{n} State" }
    sequence(:start_zip) { |n| ((n % 90_000) + 10_000).to_s }
    sequence(:start_latitude) { |n| (n % 90).to_s }
    sequence(:start_longitude) { |n| (n % 180).to_s }
    sequence(:destination_address, 1000) { |n| "#{n} Fake St" }
    sequence(:destination_city, 'a') { |n| "#{n} City" }
    sequence(:destination_state, 'a') { |n| "#{n} State" }
    sequence(:destination_zip, 1000) { |n| (((n + 5) % 90_000) + 10_000).to_s }
    sequence(:destination_latitude) { |n| ((n + 5) % 90).to_s }
    sequence(:destination_longitude) { |n| ((n + 5) % 180).to_s }
  end
end
