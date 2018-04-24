RSpec.describe Fluent::ElasticsearchSlowQueryLogParser do
  let(:parser) { described_class.new }

  describe '#parse' do
    subject { parser.parse(log) }

    include_context 'elasticsearch query'

    let(:log) do
      "[2018-04-19T00:00:02,270][TRACE][index.search.slowlog.query] [m3-hx-corelastic-data1.vinted.net] [fr-core-items_20180109082540][13] took[203ms], took_millis[203], types[item], stats[], search_type[QUERY_THEN_FETCH], total_shards[16], source[#{source}]"
    end

    let(:source) { query.to_json }

    specify do
      expect(subject.size).to eq(2)
      doc = subject[1]
      expect(doc['severity']).to eq('TRACE')
      expect(doc['source']).to eq('index.search.slowlog.query')
      expect(doc['node']).to eq('m3-hx-corelastic-data1.vinted.net')
      expect(doc['took']).to eq('203m')
      expect(doc['took_millis']).to eq(203)
      expect(doc['types']).to eq('item')
      expect(doc['stats']).to eq('')
      expect(doc['search_type']).to eq('QUERY_THEN_FETCH')
      expect(doc['total_shards']).to eq(16)
      expect(doc['source_body']).to eq(source)
      expect(doc['nq']).to eq('smart_items_lookup')
      expect(doc['country']).to eq('unknown')
    end
  end

  describe '#parse_named_query' do
    subject { parser.parse_named_query(text) }

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
end
