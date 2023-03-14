Rails.application.routes.draw do
  get 'rides/search_open_rides', to: 'rides#search_open_rides'
end
