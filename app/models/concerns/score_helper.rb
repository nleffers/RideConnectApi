# Contains methods used to calculate a Ride's score
module ScoreHelper
  extend ActiveSupport::Concern

  private

  def calculate_and_cache_score
    ride_info = route_search

    ride_distance = ride_info[:ride_distance] * 0.00062137
    commute_duration = ride_info[:commute_duration] / 60
    ride_duration = ride_info[:ride_duration] / 60

    score = calculate_score(ride_distance, ride_duration, commute_duration)
    cache_score(score)

    score
  end

  def route_search
    OpenRouteServiceApi::RouteSearch.new(current_driver.home_location,
                                         start_location,
                                         destination_location).call
  end

  def calculate_score(ride_distance, ride_duration, commute_duration)
    ride_earnings = calculate_ride_earnings(ride_distance, ride_duration)
    (ride_earnings / ((commute_duration + ride_duration) / 60)).to_i
  end

  def calculate_ride_earnings(ride_distance, ride_duration)
    ride_earnings = 12
    ride_earnings += 1.5 * (ride_distance - 5) if ride_distance > 5
    ride_earnings += 0.7 * (ride_duration - 15) if ride_duration > 15

    ride_earnings
  end

  def cache_score(score)
    Rails.cache.write(id, score, expires_in: 2.minutes)
  end

  def current_driver
    Driver.current || raise(Driver::NotLoggedInError)
  end
end
