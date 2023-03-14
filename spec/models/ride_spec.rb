RSpec.describe Ride, type: :model do
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

  describe "when getting a Ride's score" do
    let(:full_params) do
      params.merge(
        {
          start_latitude: '39.278829',
          start_longitude: '-76.622703',
          destination_latitude: '33.953414',
          destination_longitude: '-118.339026'
        }
      )
    end
    let(:ride) { described_class.create(full_params) }

    context 'when the score is stored in Redis' do
      before do
        Rails.cache.write(ride.id, 5, expires_in: 5.minutes)
      end

      after do
        Rails.cache.clear
      end

      it 'gets a score from Redis cache if one exists' do
        allow(ride).to receive(:calculate_and_cache_score)

        score = ride.score

        expect(score).to eq(5)
        expect(ride).not_to have_received(:calculate_and_cache_score)
      end
    end

    context 'when the score is not stored in Redis' do
      let(:route_params) do
        {
          coordinates: [
            ['-76.620795', '39.285217'],
            ['-76.622703', '39.278829'],
            ['-118.339026', '33.953414']
          ]
        }.to_json
      end
      let(:route_headers) do
        {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => api_key,
          'Content-Type' => 'application/json',
          'Host' => 'api.openrouteservice.org',
          'User-Agent' => 'Ruby'
        }
      end
      let(:route_response) do
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

      before { allow(Driver).to receive(:current).and_return create(:driver) }

      it 'calls the API and stores the score in Redis' do
        stub_request(:post, 'https://api.openrouteservice.org/v2/directions/driving-car')
          .with(body: route_params, headers: route_headers)
          .to_return(body: route_response, status: 200, headers: route_headers)

        score = ride.score
        expect(score).to eq(134)
      end
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
end
