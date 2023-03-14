# Controller for Rides
class RidesController < ApplicationController
  # And lots of rspec tests. But this won't be too bad. Just glad I didn't wait until Tuesday to start this.
  # Oh, and I need to write the markdown for how the API works.
  # And leave good comments.
  # And implement good error handling.
  def search_open_rides
    # get open rides
    rides = Ride.open_rides

    # get each ride's score
    ride_scores = get_ride_scores(rides)

    # sort results by score, best to worst
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
