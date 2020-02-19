RSpec.describe Fluent::Plugin::ElasticsearchSlowQueryLogParser do
  let(:parser) { described_class.new }

  describe '#parse' do
    subject { parser.parse(log_text) }

    include_context 'elasticsearch query'

    let(:log_text) { File.read('spec/files/elasticsearch-5-slow-query-log-01.log').lines.first }

    let(:source) {
      query.to_json
    }
    let(:log) { subject[1] }

    specify do
      expect(subject.size).to eq(2)
      expect(log).not_to be_nil
      expect(log['severity']).to eq('TRACE')
      expect(log['source']).to eq('index.search.slowlog.query')
      expect(log['node']).to eq('m1-machine.net')
      expect(log['index']).to eq('fr-core-items_555')
      expect(log['took']).to eq('261.6m')
      expect(log['took_millis']).to eq(261)
      expect(log['types']).to eq('item')
      expect(log['stats']).to eq('')
      expect(log['search_type']).to eq('QUERY_THEN_FETCH')
      expect(log['total_shards']).to eq(84)
      expect(JSON.parse(log['source_body'])).to eq({"very_slow_query"=>"n84zm5vo5qax"})
      expect(log['nq']).to eq('unknown')
      expect(log['country']).to eq('unknown')
      expect(log['source_body_from']).to eq(nil)
      expect(log['source_body_size']).to eq(nil)
      expect(log['total_hits']).to eq(nil)
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
