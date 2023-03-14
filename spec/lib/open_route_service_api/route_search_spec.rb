RSpec.describe OpenRouteServiceApi::RouteSearch do
  let(:api_key) { Rails.application.credentials.open_route_service.api_key }
  let(:driver_location) do
    {
      latitude: '39.285217',
      longitude: '-76.620795'
    }
  end
  let(:start_location) do
    {
      latitude: '39.278829',
      longitude: '-76.622703'
    }
  end
  let(:empty_start_location) do
    {
      latitude: '39.278829',
      longitude: nil
    }
  end
  let(:destination_location) do
    {
      latitude: '33.953414',
      longitude: '-118.339026'
    }
  end

  context 'when initializing a RouteSearch' do
    it 'creates a location attr_accessor' do
      new_route_search = described_class.new(driver_location, start_location, destination_location)
      expect(new_route_search.driver_location).to eq(driver_location)
      expect(new_route_search.start_location).to eq(start_location)
      expect(new_route_search.destination_location).to eq(destination_location)
    end
  end

  context 'when calling a RouteSearch' do
    let(:headers) do
      {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Authorization' => api_key,
        'Content-Type' => 'application/json',
        'Host' => 'api.openrouteservice.org',
        'User-Agent' => 'Ruby'
      }
    end
    let(:params) do
      {
        coordinates: [
          [driver_location[:longitude], driver_location[:latitude]],
          [start_location[:longitude], start_location[:latitude]],
          [destination_location[:longitude], destination_location[:latitude]]
        ]
      }.to_json
    end
    let(:empty_params) do
      {
        coordinates: [
          [driver_location[:longitude], driver_location[:latitude]],
          [nil, start_location[:latitude]],
          [destination_location[:longitude], destination_location[:latitude]]
        ]
      }.to_json
    end
    let(:resp_body) do
      {
        routes: [
          {
            segments: [
              {
                distance: 977.8,
                duration: 125.0
              },
              {
                distance: 4_264_799.0,
                duration: 153_889.2
              }
            ]
          }
        ]
      }.to_json
    end
    let(:expected_call_response) do
      {
        commute_duration: 125.0,
        ride_distance: 4_264_799.0,
        ride_duration: 153_889.2
      }
    end

    it 'returns coordinates for a given location' do
      stub_request(:post, 'https://api.openrouteservice.org/v2/directions/driving-car')
        .with(body: params, headers:)
        .to_return(body: resp_body, status: 200, headers:)

      expect(
        described_class.new(driver_location, start_location, destination_location).call
      ).to eq(expected_call_response)
    end

    it 'raises RouteSearchError when any coordinate is missing' do
      stub_request(:post, 'https://api.openrouteservice.org/v2/directions/driving-car')
        .with(body: empty_params, headers:)
        .to_return(body: '', status: 200, headers:)

      new_route_search = described_class.new(driver_location, empty_start_location, destination_location)

      expect { new_route_search.call }.to raise_error(OpenRouteServiceApi::RouteSearchError)
    end
  end
end
