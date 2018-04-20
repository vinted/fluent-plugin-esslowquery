RSpec.describe Fluent::ElasticsearchSlowQueryLogParser::NamedQuery do
  subject { described_class.parse(text) }

  let(:parsed_fields) { { 'query_name' => query_name, 'country' => country } }

  context 'with named query' do
    let(:text) { '"_name": "NQ: query_name"' }
    let(:query_name) { 'query_name' }
    let(:country) { 'unknown' }

    it { is_expected.to eq(parsed_fields) }
  end

  context 'with named query and country' do
    let(:text) { '"_name": "NQ: query_name|COUNTRY: lt"' }
    let(:query_name) { 'query_name' }
    let(:country) { 'lt' }

    it { is_expected.to eq(parsed_fields) }
  end

  context 'with not matching text' do
    let(:text) { 'not matching' }
    let(:query_name) { 'unknown' }
    let(:country) { 'unknown' }

    it { is_expected.to eq(parsed_fields) }
  end
end
