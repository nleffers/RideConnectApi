RSpec.describe Driver do
  let(:api_key) { Rails.application.credentials.open_route_service.api_key }

  it { is_expected.to have_many(:rides) }

  context 'when creating a new driver' do
    let(:location_headers) do
      {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Host' => 'api.openrouteservice.org',
        'User-Agent' => 'Ruby'
      }
    end
    let(:params) do
      {
        home_address: '1101 Russell St',
        home_city: 'Baltimore',
        home_state: 'MD',
        home_zip: '21230'
      }
    end
    let(:empty_params) do
      {
        home_address: nil,
        home_city: nil,
        home_state: nil,
        home_zip: nil
      }
    end
    let(:location_url) do
      "https://api.openrouteservice.org/geocode/search/structured?api_key=#{api_key}&" \
        "address=#{params[:home_address]}&locality=#{params[:home_city]}&" \
        "region=#{params[:home_state]}&postalCode=#{params[:home_zip]}"
    end
    let(:location_body) do
      {
        features: [
          {
            geometry: {
              coordinates: [-76.620795, 39.285217]
            }
          }
        ]
      }.to_json
    end

    it 'gets lat/long from OpenRouteService API and updates Driver before create' do
      stub_request(:get, location_url)
        .with(headers: location_headers)
        .to_return(body: location_body, status: 200, headers: location_headers)

      driver = described_class.create(params)

      expect(driver.home_latitude).not_to be_nil
      expect(driver.home_longitude).not_to be_nil
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

  context 'when calling Driver.current' do
    let(:driver) { create(:driver) }

    it 'gets the current driver' do
      expect(described_class.current).to be_nil
      described_class.current = driver
      expect(described_class.current).to be(driver)
    end
  end
end
