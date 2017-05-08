module Fluent
  class ElasticsearchSlowQueryLogParser < Parser
    time = /^\[(?<time>\d{4}-\d{2}-\d{2}.*\d{2}:\d{2}:\d{2},\d{3})\]/
    severity = /\[(?<severity>[a-zA-Z]+\s*)\]/
    source = /\[(?<source>\S+)\]/
    node = /\[(?<node>\S+)\]/
    index = /\[(?<index>[-a-zA-Z0-9_]+)\]/
    shard = /\[(?<shard>\S+)\]/
    took = /took\[(?<took>\S+)m?s\]/
    took_millis = /took_millis\[(?<took_millis>\d+)\]/
    types = /types\[(?<types>.*)\]/
    stats = /stats\[(?<stats>)\]/
    search_type = /search_type\[(?<search_type>.*)\]/
    total_shards = /total_shards\[(?<total_shards>\d+)\]/
    source_body = /source\[(?<source_body>.*)\]/

    REGEXP = /#{time}#{severity}#{source} #{node} #{index}#{shard} #{took}, #{took_millis}, #{types}, #{stats}, #{search_type}, #{total_shards}, #{source_body}/

    TIME_FORMAT = "%Y-%m-%dT%H:%M:%S,%N"

    Plugin.register_parser("es_slow_query", self)

    def initialize
      super
      @time_parser = TextParser::TimeParser.new(TIME_FORMAT)
      @mutex = Mutex.new
    end

    def patterns
      {'format' => REGEXP, 'time_format' => TIME_FORMAT}
    end

    def parse(text)
      m = REGEXP.match(text)
      unless m
        if block_given?
          yield nil, nil
          return
        else
          return nil, nil
        end
      end

      shard = m['shard'].to_i
      took_millis = m['took_millis'].to_i
      total_shards = m['total_shards'].to_i

      time = m['time']
      time = @mutex.synchronize { @time_parser.parse(time) }

      record = {
        'severity' => m['severity'],
        'source' => m['source'],
        'node' => m['node'],
        'index' => m['index'],
        'shard' => shard,
        'took' => m['took'],
        'took_millis' => took_millis,
        'types' => m['types'],
        'stats' => m['stats'],
        'search_type' => m['search_type'],
        'total_shards' => total_shards,
        'source_body' => m['source_body'],
      }
      record["time"] = m['time'] if @keep_time_key

      if block_given?
        yield time, record
      else
        return time, record
      end
    end
  end
end
