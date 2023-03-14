# Model that represents Ride object
class Ride < ApplicationRecord
  include AddressHelper
  include ScoreHelper

  belongs_to :driver, optional: true

  before_create :update_start_lat_long, unless: :start_lat_long_present?
  before_create :update_destination_lat_long, unless: :destination_lat_long_present?

  # List of Rides not already associated with a Driver
  def self.open_rides
    where(driver_id: nil)
  end

  # Ride's score for the logged in Driver
  # Checks Redis for an already existing score
  def score
    Rails.cache.read("driver_#{Driver.current.id}_ride_#{id}") || calculate_and_cache_score
  end

  # Ride's starting location information
  def start_location
    location('start')
  end

  # Ride's destination location information
  def destination_location
    location('destination')
  end

  private

  # Update starting latitude/longitude using OpenRouteServiceApi::LocationSearch
  def update_start_lat_long
    update_lat_long('start')
  end

  # Update destination latitude/longitude using OpenRouteServiceApi::LocationSearch
  def update_destination_lat_long
    update_lat_long('destination')
  end

  # Check if starting latitude/longitude are already present
  def start_lat_long_present?
    lat_long_present?('start')
  end

  # Check if destination latitude/longitude are already present
  def destination_lat_long_present?
    lat_long_present?('destination')
  end
end
