# Model that represents Ride object
class Ride < ApplicationRecord
  include AddressHelper
  include ScoreHelper

  belongs_to :driver, optional: true

  before_create :update_start_lat_long, unless: :start_lat_long_present?
  before_create :update_destination_lat_long, unless: :destination_lat_long_present?

  def self.open_rides
    where(driver_id: nil)
  end

  def score
    Rails.cache.read(id) || calculate_and_cache_score
  end

  def start_location
    location('start')
  end

  def destination_location
    location('destination')
  end

  private

  def update_start_lat_long
    update_lat_long('start')
  end

  def update_destination_lat_long
    update_lat_long('destination')
  end

  def start_lat_long_present?
    lat_long_present?('start')
  end

  def destination_lat_long_present?
    lat_long_present?('destination')
  end
end
