# frozen_string_literal: true

module OpenRouteServiceApi
  class LocationSearchError < StandardError; end

  # Class that gets coordinates from OpenRouteService API
  class LocationSearch
    API_ENDPOINT = 'https://api.openrouteservice.org/geocode/search/structured'

    attr_accessor :location

    def initialize(location)
      @location = location
    end

    # Get location information from OpenRouteService Geocode Services
    def call
      resp = send_get_request

      check_response_for_error(resp.code)

      coordinates = JSON.parse(resp.body)['features'][0]['geometry']['coordinates']
      {
        latitude: coordinates[1],
        longitude: coordinates[0]
      }
    end

    private

    # Make the GET request to the API
    def send_get_request
      uri = URI(API_ENDPOINT)
      uri.query = URI.encode_www_form(params)
      Net::HTTP.get_response(uri)
    end

    # Parameters needed for the GET request
    def params
      {
        api_key: Rails.application.credentials.open_route_service.api_key,
        address: location[:address],
        locality: location[:city],
        region: location[:state],
        postalCode: location[:zip]
      }
    end

    # Raise error if GET request was unsuccessful
    def check_response_for_error(status_code)
      return if JSON.parse(status_code) == 200

      raise(OpenRouteServiceApi::LocationSearchError, status_code)
    end
  end
end
