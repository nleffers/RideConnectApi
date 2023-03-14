shared_examples_for 'location_helper' do |prefix|
  let(:object) { FactoryBot.build(described_class.to_s.underscore.to_sym) }
  let(:location_keys) { %i[address city state zip latitude longitude] }

  it 'returns location info' do
    expect(object.send("#{prefix}_location").keys).to match_array(location_keys)
  end
end
