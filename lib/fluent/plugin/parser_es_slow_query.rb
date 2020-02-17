module Fluent
  module Plugin
    class ElasticsearchSlowQueryLogParser < Parser
      Plugin.register_parser("es_slow_query", self)
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
      source_body = /source\[(?<source_body>.*)\](\n|, id\[(?<id>.*)\])/
      total_hits = /total_hits\[(?<total_hits>\d+)\]/
      
      REGEXP = /#{time}#{severity}#{source} #{node} #{index}#{shard} #{took}, #{took_millis}(, #{total_hits})?, #{types}, #{stats}, #{search_type}, #{total_shards}, #{source_body}/
      NAMED_QUERY_REGEX = /"_name":\s?"NQ: (?<query_name>.*?)(\|COUNTRY: (?<country>.*?(?=\")))?"/
      TIME_FORMAT = "%Y-%m-%dT%H:%M:%S,%N"

      def initialize
        super
        @time_parser = Fluent::TimeParser.new(TIME_FORMAT)
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

        took_millis = m['took_millis'].to_i
        total_shards = m['total_shards'].to_i

        time = m['time']
        time = @mutex.synchronize { @time_parser.parse(time) }

        source_body = m['source_body']
        parsed_source_body = JSON.parse(source_body)

        nq = parse_named_query(source_body)

        record = {
          'severity' => m['severity'],
          'source' => m['source'],
          'node' => m['node'],
          'index' => m['index'],
          'took' => m['took'],
          'took_millis' => took_millis,
          'types' => m['types'],
          'stats' => m['stats'],
          'search_type' => m['search_type'],
          'total_shards' => total_shards,
          'source_body' => source_body,
          'nq' => nq['query_name'],
          'country' => nq['country'],
          'source_body_from' => parsed_source_body['from'],
          'source_body_size' => parsed_source_body['size'],
          'total_hits' => m['total_hits'],
        }
        record["time"] = m['time'] if @keep_time_key

        if block_given?
          yield time, record
        else
          return time, record
        end
      end

      def parse_named_query(text)
        matched_data = NAMED_QUERY_REGEX.match(text)
        matched = matched_data && matched_data.captures || []

        {
          'query_name' => matched[0] || 'unknown',
          'country' => matched[1] || 'unknown',
        }
      end
    end
  end
end
