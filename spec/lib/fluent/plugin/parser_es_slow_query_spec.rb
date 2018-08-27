RSpec.describe Fluent::Plugin::ElasticsearchSlowQueryLogParser do
  let(:parser) { described_class.new }

  describe '#parse' do
    subject { parser.parse(log_text) }

    include_context 'elasticsearch query'

    let(:log_text) do
      "[2018-04-19T00:00:02,270][TRACE][index.search.slowlog.query] [m3-hx-corelastic-data1.vinted.net] [fr-core-items_20180109082540][13] took[203ms], took_millis[203], types[item], stats[], search_type[QUERY_THEN_FETCH], total_shards[16], source[#{source}]"
    end

    let(:source) { query.to_json }
    let(:log) { subject[1] }

    specify do
      expect(subject.size).to eq(2)
      expect(log).not_to be_nil
      expect(log['severity']).to eq('TRACE')
      expect(log['source']).to eq('index.search.slowlog.query')
      expect(log['node']).to eq('m3-hx-corelastic-data1.vinted.net')
      expect(log['index']).to eq('fr-core-items_20180109082540')
      expect(log['took']).to eq('203m')
      expect(log['took_millis']).to eq(203)
      expect(log['types']).to eq('item')
      expect(log['stats']).to eq('')
      expect(log['search_type']).to eq('QUERY_THEN_FETCH')
      expect(log['total_shards']).to eq(16)
      expect(log['source_body']).to eq(source)
      expect(log['nq']).to eq('smart_items_lookup')
      expect(log['country']).to eq('unknown')
    end
  end

  describe '#parse_named_query' do
    subject { parser.parse_named_query(text) }

    let(:parsed_fields) { { 'query_name' => query_name, 'country' => country } }

    context 'with named query' do
      let(:text) { '"_name": "NQ: query_name", "other_key": "other_value"' }
      let(:query_name) { 'query_name' }
      let(:country) { 'unknown' }

      it { is_expected.to eq(parsed_fields) }
    end

    context 'with country' do
      let(:text) { '"_name": "NQ: query_name|COUNTRY: lt", "other_key": "other_value"' }
      let(:query_name) { 'query_name' }
      let(:country) { 'lt' }

      it { is_expected.to eq(parsed_fields) }
    end

    context 'with underscored country' do
      let(:text) { '"_name": "NQ: query_name|COUNTRY: sb_lt_babies", "other_key": "other_value"' }
      let(:query_name) { 'query_name' }
      let(:country) { 'sb_lt_babies' }

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
