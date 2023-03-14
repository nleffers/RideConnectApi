# Controller for Rides
class RidesController < ApplicationController
  # Returns a list of rides sorted by their scores in relation to the current Driver
  def search_open_rides
    # Check that Driver is logged in
    raise(Driver::NotLoggedInError) unless Driver.current

    # Get open rides
    rides = Ride.open_rides

    # Get each ride's score
    ride_scores = get_ride_scores(rides)

    # Sort results by score, best to worst
    ride_scores.sort! { |a, b| b[:score] <=> a[:score] }

    render json: ride_scores, status: :ok
  rescue Driver::NotLoggedInError
    head :unauthorized
  rescue OpenRouteServiceApi::RouteSearchError
    head :bad_request
  end

  private

  # Get ride score from either Redis or API call
  def get_ride_scores(rides)
    rides.map do |ride|
      {
        id: ride.id,
        score: ride.score
      }
    end
  end
end
