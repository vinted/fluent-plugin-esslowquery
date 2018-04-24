class Fluent::ElasticsearchSlowQueryLogParser::NamedQuery
  def self.parse(text)
    regex = /"_name":\s?"NQ: (?<query_name>.*?)(\|COUNTRY: (?<country>lt))?"/
    matched = regex.match(text)&.named_captures || {}

    {
      'query_name' => matched['query_name'] || 'unknown',
      'country' => matched['country'] || 'unknown',
    }
  end
end
