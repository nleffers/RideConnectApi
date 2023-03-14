FactoryBot.define do
  factory :driver do
    home_address { '333 W Camden St' }
    home_city { 'Baltimore' }
    home_state { 'MD' }
    home_zip { '21201' }
    home_latitude { '39.285217' }
    home_longitude { '-76.620795' }

    factory :random_driver do
      sequence(:home_address) { |n| "#{n} Fake St" }
      sequence(:home_city, 'A') { |n| "#{n} City" }
      sequence(:home_state, 'A') { |n| "#{n} State" }
      sequence(:home_zip) { |n| (n % 90_000 + 10_000).to_s }
      sequence(:home_latitude) { |n| (n % 90).to_s }
      sequence(:home_longitude) { |n| (n % 180).to_s }
    end
  end
end
