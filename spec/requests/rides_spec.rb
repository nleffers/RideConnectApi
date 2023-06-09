RSpec.describe Ride do
  describe 'GET /search_open_rides' do
    let(:api_key) { Rails.application.credentials.open_route_service.api_key }
    let(:driver) { create(:driver) }

    before(:each, :create_five_rides) do
      create_list(:ride, 5)
    end

    after { Rails.cache.clear }

    context 'when ride scores are stored in Redis', :create_five_rides do
      before do
        described_class.all.each_with_index do |ride, index|
          Rails.cache.write("driver_#{driver.id}_ride_#{ride.id}", index % 3, expires_in: 5.seconds)
        end
      end

      it 'returns all rides sorted by their scores' do
        get '/rides/search_open_rides', params: { driver_id: driver.id }

        results = response.parsed_body
        expect(results.count).to eq(5)
        expect(results.first['score']).to be >= results.last['score']
      end

      it 'returns only open rides sorted by their scores' do
        new_driver = create(:random_driver)

        described_class.first.update(driver: new_driver)
        get '/rides/search_open_rides', params: { driver_id: driver.id }

        results = response.parsed_body
        expect(results.count).to eq(4)
        expect(results.first['score']).to be >= results.last['score']
      end
    end

    context 'when ride scores are not stored in Redis' do
      before { create_list(:ride, 2) }

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
      let(:coordinates_stub_first) do
        {
          coordinates: [
            [driver.home_longitude, driver.home_latitude],
            [described_class.first.start_longitude, described_class.first.start_latitude],
            [described_class.first.destination_longitude, described_class.first.destination_latitude]
          ]
        }.to_json
      end
      let(:coordinates_stub_last) do
        {
          coordinates: [
            [driver.home_longitude, driver.home_latitude],
            [described_class.last.start_longitude, described_class.last.start_latitude],
            [described_class.last.destination_longitude, described_class.last.destination_latitude]
          ]
        }.to_json
      end
      let(:coordinates_stub_bad) do
        {
          coordinates: [
            [driver.home_longitude, driver.home_latitude],
            [nil, described_class.first.start_latitude],
            [described_class.first.destination_longitude, described_class.first.destination_latitude]
          ]
        }.to_json
      end
      let(:route_first_response) do
        {
          routes: [
            {
              segments: [
                {
                  distance: 100.0,
                  duration: 50.0
                },
                {
                  distance: 200.0,
                  duration: 100.0
                }
              ]
            }
          ]
        }.to_json
      end
      let(:route_last_response) do
        {
          routes: [
            {
              segments: [
                {
                  distance: 25.0,
                  duration: 5.0
                },
                {
                  distance: 35.0,
                  duration: 10.0
                }
              ]
            }
          ]
        }.to_json
      end

      it 'caches all ride scores and returns them' do
        stub_request(:post, 'https://api.openrouteservice.org/v2/directions/driving-car')
          .with(body: coordinates_stub_first, headers:)
          .to_return(body: route_first_response, status: 200, headers:)
        stub_request(:post, 'https://api.openrouteservice.org/v2/directions/driving-car')
          .with(body: coordinates_stub_last, headers:)
          .to_return(body: route_last_response, status: 200, headers:)

        described_class.all.each do |ride|
          expect(Rails.cache.read("driver_#{driver.id}_ride_#{ride.id}").present?).to be(false)
        end

        get '/rides/search_open_rides', params: { driver_id: driver.id }

        described_class.all.each do |ride|
          expect(Rails.cache.read("driver_#{driver.id}_ride_#{ride.id}").present?).to be(true)
        end

        results = response.parsed_body
        expect(results.count).to eq(2)
        expect(results.first['score']).to be >= results.last['score']
      end

      it 'returns a 400 when OpenRouteService Directions Service fails' do
        described_class.first.update(start_longitude: nil)

        stub_request(:post, 'https://api.openrouteservice.org/v2/directions/driving-car')
          .with(body: coordinates_stub_bad, headers:)
          .to_return(status: 400, headers:)

        get '/rides/search_open_rides', params: { driver_id: driver.id }

        expect(response.code).to eq('400')
      end
    end

    context 'when Driver does not exist', :create_five_rides do
      it 'returns a 404' do
        get '/rides/search_open_rides', params: { driver_id: driver.id + 1 }

        expect(response.code).to eq('404')
      end
    end
  end
end
