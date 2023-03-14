# Model that represents Driver object
class Driver < ApplicationRecord
  include LocationHelper

  has_many :rides, dependent: :restrict_with_exception

  before_create :update_home_lat_long, unless: :home_lat_long_present?

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
