# Model that represents Driver object
class Driver < ApplicationRecord
  include LocationHelper

  has_many :rides, dependent: :restrict_with_exception

  before_create :update_home_lat_long, unless: :home_lat_long_present?

  # Used in rides#search_open_rides, which requires a logged in Driver to get commute information
  class NotLoggedInError < StandardError; end

  # Logged in Driver
  def self.current
    Current.driver
  end

  # Log in Driver
  def self.current=(driver)
    Current.driver = driver
  end

  # Driver's Home Location
  def home_location
    location('home')
  end

  private

  # Update latitude/longitude using OpenRouteServiceApi::LocationSearch
  def update_home_lat_long
    update_lat_long('home')
  end

  # Check if latitude/longitude are already present
  def home_lat_long_present?
    lat_long_present?('home')
  end
end
