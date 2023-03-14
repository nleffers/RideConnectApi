# Contains methods used to calculate a Ride's score
module RideScoreHelper
  extend ActiveSupport::Concern

  private

  # Base function used to calculate a Ride's score and cache it into Redis
  def calculate_and_cache_score(ride)
    ride_info = route_search(ride)

    ride_distance = ride_info[:ride_distance] * 0.00062137
    commute_duration = ride_info[:commute_duration] / 60
    ride_duration = ride_info[:ride_duration] / 60

    score = calculate_score(ride_distance, ride_duration, commute_duration)
    cache_score(score, ride.id)

    score
  end

  # Get Ride's route information using OpenRouteService Directions Service
  def route_search(ride)
    OpenRouteServiceApi::RouteSearch.new(driver.home_location,
                                         ride.start_location,
                                         ride.destination_location).call
  end

  # Calculate Ride score
  def calculate_score(ride_distance, ride_duration, commute_duration)
    ride_earnings = calculate_ride_earnings(ride_distance, ride_duration)
    (ride_earnings / ((commute_duration + ride_duration) / 60)).to_i
  end

  # Calculate Ride potential earnings
  def calculate_ride_earnings(ride_distance, ride_duration)
    ride_earnings = 12
    ride_earnings += 1.5 * (ride_distance - 5) if ride_distance > 5
    ride_earnings += 0.7 * (ride_duration - 15) if ride_duration > 15

    ride_earnings
  end

  # Cache Ride score in Redis and set an expiration time so data can eventually be updated
  # Redis key personalized to current Driver, as commute info - and thus the Ride score - is personalized to the Driver
  def cache_score(score, ride_id)
    Rails.cache.write("driver_#{driver_params[:driver_id]}_ride_#{ride_id}", score, expires_in: 2.minutes)
  end

  # Find given Driver
  # Raises ActiveRecord::RecordNotFound if Driver doesn't exist
  def driver
    Driver.find(driver_params[:driver_id])
  end
end