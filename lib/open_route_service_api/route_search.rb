# frozen_string_literal: true

module OpenRouteServiceApi
  class RouteSearchError < StandardError; end

  # Class that gets route info from OpenRouteService API
  class RouteSearch
    API_ENDPOINT = 'https://api.openrouteservice.org/v2/directions/driving-car'

    attr_accessor :driver_location, :start_location, :destination_location

    def initialize(driver_location, start_location, destination_location)
      @driver_location = driver_location
      @start_location = start_location
      @destination_location = destination_location
    end

    # Get commute and ride info from OpenRouteService Directions Service
    def call
      resp = send_post_request
      check_response_for_error(resp)

      segments = JSON.parse(resp.body)['routes'][0]['segments']
      commute_segment = segments[0]
      ride_segment = segments[1]

      {
        commute_duration: commute_segment['duration'], # seconds
        ride_distance: ride_segment['distance'], # meters
        ride_duration: ride_segment['duration'] # seconds
      }
    end

    private

    # Make the POST request to the API
    def send_post_request
      uri = URI(API_ENDPOINT)

      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true

      req = https_request(uri)
      https.request(req)
    end

    # Set up the POST request
    def https_request(uri)
      req = Net::HTTP::Post.new(uri)
      req.content_type = 'application/json'
      req['Authorization'] = Rails.application.credentials.open_route_service.api_key
      req.body = params.to_json

      req
    end

    # Parameters needed for the POST request
    def params
      {
        coordinates: [
          [driver_location[:longitude], driver_location[:latitude]],
          [start_location[:longitude], start_location[:latitude]],
          [destination_location[:longitude], destination_location[:latitude]]
        ]
      }
    end

    # Raise error if POST request was unsuccessful
    def check_response_for_error(resp)
      return if JSON.parse(resp.code) == 200 && resp.body.present?

      raise(OpenRouteServiceApi::RouteSearchError)
    end
  end
end
