# Model that represents Driver object
class Driver < ApplicationRecord
  include AddressHelper

  has_many :rides, dependent: :restrict_with_exception

  before_create :update_home_lat_long, unless: :home_lat_long_present?

  class NotLoggedInError < StandardError; end

  def self.current
    Current.driver
  end

  def self.current=(driver)
    Current.driver = driver
  end

  def home_location
    location('home')
  end

  private

  def update_home_lat_long
    update_lat_long('home')
  end

  def home_lat_long_present?
    lat_long_present?('home')
  end
end
