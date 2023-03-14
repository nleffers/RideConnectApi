# Address Helper
module AddressHelper
  extend ActiveSupport::Concern

  private

  # Used by Driver and Ride to get location information
  def location(prefix)
    {
      address: send("#{prefix}_address"),
      city: send("#{prefix}_city"),
      state: send("#{prefix}_state"),
      zip: send("#{prefix}_zip"),
      latitude: send("#{prefix}_latitude"),
      longitude: send("#{prefix}_longitude")
    }
  end

  # Update latitude/longitude using OpenRouteServiceApi::LocationSearch
  def update_lat_long(prefix)
    return if send("#{prefix}_latitude") && send("#{prefix}_longitude")

    coordinates = OpenRouteServiceApi::LocationSearch.new(send("#{prefix}_location")).call

    self.attributes = {
      "#{prefix}_latitude" => coordinates[:latitude],
      "#{prefix}_longitude" => coordinates[:longitude]
    }
  end

  # Check if latitude/longitude are already present
  def lat_long_present?(prefix)
    send("#{prefix}_latitude").present? && send("#{prefix}_longitude").present?
  end
end
