RSpec.describe Ride do
  let(:api_key) { Rails.application.credentials.open_route_service.api_key }
  let(:params) do
    {
      start_address: '1101 Russell St',
      start_city: 'Baltimore',
      start_state: 'MD',
      start_zip: '21230',
      destination_address: '1001 Stadium Dr',
      destination_city: 'Inglewood',
      destination_state: 'CA',
      destination_zip: '90301'
    }
  end
  let(:empty_params) do
    {
      start_address: nil,
      start_city: nil,
      start_state: nil,
      start_zip: nil,
      destination_address: nil,
      destination_city: nil,
      destination_state: nil,
      destination_zip: nil
    }
  end
  let(:location_headers) do
    {
      'Accept' => '*/*',
      'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Host' => 'api.openrouteservice.org',
      'User-Agent' => 'Ruby'
    }
  end

  it { is_expected.to belong_to(:driver).optional }

  context 'when creating a Ride' do
    let(:start_url) do
      "https://api.openrouteservice.org/geocode/search/structured?api_key=#{api_key}&" \
        "address=#{params[:start_address]}&locality=#{params[:start_city]}&" \
        "region=#{params[:start_state]}&postalCode=#{params[:start_zip]}"
    end
    let(:start_resp_body) do
      {
        features: [
          {
            geometry: {
              coordinates: [-76.622703, 39.278829]
            }
          }
        ]
      }.to_json
    end
    let(:destination_url) do
      "https://api.openrouteservice.org/geocode/search/structured?api_key=#{api_key}&" \
        "address=#{params[:destination_address]}&locality=#{params[:destination_city]}&" \
        "region=#{params[:destination_state]}&postalCode=#{params[:destination_zip]}"
    end
    let(:destination_resp_body) do
      {
        features: [
          {
            geometry: {
              coordinates: [-118.339026, 33.953414]
            }
          }
        ]
      }.to_json
    end

    it 'gets lat/long from OpenRouteService API and updates Driver before create' do
      stub_request(:get, start_url)
        .with(headers: location_headers)
        .to_return(body: start_resp_body, status: 200, headers: location_headers)
      stub_request(:get, destination_url)
        .with(headers: location_headers)
        .to_return(body: destination_resp_body, status: 200, headers: location_headers)

      ride = described_class.create(params)

      expect(ride.start_latitude).to eq('39.278829')
      expect(ride.start_longitude).to eq('-76.622703')
      expect(ride.destination_latitude).to eq('33.953414')
      expect(ride.destination_longitude).to eq('-118.339026')
    end

    it 'fails when a location is missing' do
      stub_request(
        :get,
        "https://api.openrouteservice.org/geocode/search/structured?api_key=#{api_key}&address&locality&region&postalCode"
      )
        .with(headers: location_headers)
        .to_return(body: { features: [] }.to_json, status: 400, headers: location_headers)

      expect { described_class.create(empty_params) }.to raise_error(OpenRouteServiceApi::LocationSearchError)
    end
  end

  context 'when Ride.open_rides is called' do
    before { create_list(:ride, 5) }

    it 'returns all open rides' do
      expect(described_class.open_rides.count).to eq(5)
    end

    it 'returns only open rides' do
      described_class.first.update(driver: create(:driver))

      expect(described_class.open_rides.count).to eq(4)
    end
  end

  context 'when start_location is called' do
    it_behaves_like 'location_helper', 'start'
  end

  context 'when destination_location is called' do
    it_behaves_like 'location_helper', 'destination'
  end
end
