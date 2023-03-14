RSpec.describe OpenRouteServiceApi::LocationSearch do
  let(:api_key) { Rails.application.credentials.open_route_service.api_key }
  let(:headers) do
    {
      'Accept' => '*/*',
      'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Host' => 'api.openrouteservice.org',
      'User-Agent' => 'Ruby'
    }
  end
  let(:params) do
    {
      address: '1101 Russell St',
      city: 'Baltimore',
      state: 'MD',
      zip: '21230'
    }
  end

  context 'when initializing a LocationSearch' do
    it 'creates a location attr_accessor' do
      expect(described_class.new(params).location).to eq(params)
    end
  end

  context 'when calling a LocationSearch' do
    let(:url) do
      "https://api.openrouteservice.org/geocode/search/structured?api_key=#{api_key}&" \
        "address=#{params[:address]}&locality=#{params[:city]}&" \
        "region=#{params[:state]}&postalCode=#{params[:zip]}"
    end
    let(:resp_body) do
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
    let(:expected_call_response) do
      {
        latitude: 39.285217,
        longitude: -76.620795
      }
    end

    it 'returns coordinates for a given location' do
      stub_request(:get, url)
        .with(headers:)
        .to_return(body: resp_body, status: 200, headers:)

      expect(described_class.new(params).call).to eq(expected_call_response)
    end
  end

  context 'when there is no location' do
    let(:empty_params) do
      {
        address: nil,
        city: nil,
        state: nil,
        zip: nil
      }
    end
    let(:url) do
      "https://api.openrouteservice.org/geocode/search/structured?api_key=#{api_key}&address&locality&region&postalCode"
    end
    let(:resp_body) do
      {
        features: []
      }.to_json
    end

    it 'raises LocationSearchError' do
      stub_request(:get, url)
        .with(headers:)
        .to_return(body: resp_body, status: 400, headers:)

      expect { described_class.new(empty_params).call }.to raise_error(OpenRouteServiceApi::LocationSearchError)
    end
  end
end
