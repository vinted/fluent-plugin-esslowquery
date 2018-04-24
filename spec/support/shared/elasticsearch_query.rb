RSpec.shared_context 'elasticsearch query' do
  let(:query) do
    {
      "from" => 0,
      "size" => 24,
      "timeout" => "800ms",
      "query" => {
        "function_score" => {
          "query" => {
            "bool" => {
              "must" => [
                {
                  "constant_score" => {
                    "filter" => {
                      "match" => {
                        "_all" => {
                          "query" => "",
                          "operator" => "AND",
                          "analyzer" => "default_search",
                          "prefix_length" => 0,
                          "max_expansions" => 50,
                          "fuzzy_transpositions" => true,
                          "lenient" => false,
                          "zero_terms_query" => "ALL",
                          "boost" => 1.0
                        }
                      }
                    },
                    "boost" => 1.0
                  }
                }
              ],
              "filter" => [
                {
                  "bool" => {
                    "must" => [
                      {
                        "terms" => {
                          "catalog_ids" => [
                            4
                          ],
                          "boost" => 1.0
                        }
                      },
                      {
                        "range" => {
                          "user_updated_at" => {
                            "from" => nil,
                            "to" => nil,
                            "include_lower" => true,
                            "include_upper" => true,
                            "boost" => 1.0
                          }
                        }
                      },
                      {
                        "range" => {
                          "created_at" => {
                            "from" => nil,
                            "to" => nil,
                            "include_lower" => true,
                            "include_upper" => true,
                            "boost" => 1.0
                          }
                        }
                      },
                      {
                        "term" => {
                          "is_visible" => {
                            "value" => true,
                            "boost" => 1.0
                          }
                        }
                      },
                      {
                        "term" => {
                          "is_closed" => {
                            "value" => false,
                            "boost" => 1.0
                          }
                        }
                      }
                    ],
                    "must_not" => [
                      {
                        "exists" => {
                          "field" => "stress_test",
                          "boost" => 1.0
                        }
                      },
                      {
                        "exists" => {
                          "field" => "user_shadow_banned",
                          "boost" => 1.0
                        }
                      }
                    ],
                    "disable_coord" => false,
                    "adjust_pure_negative" => true,
                    "boost" => 1.0
                  }
                }
              ],
              "disable_coord" => false,
              "adjust_pure_negative" => true,
              "boost" => 1.0,
              "_name" => "NQ: smart_items_lookup"
            }
          },
          "functions" => [
            {
              "filter" => {
                "match_all" => {
                  "boost" => 1.0
                }
              },
              "script_score" => {
                "script" => {
                  "inline" => "1 / ln(now - doc['user_updated_at'].value + 1)",
                  "lang" => "expression",
                  "params" => {
                    "now" => 1524095942063
                  }
                }
              }
            },
            {
              "filter" => {
                "range" => {
                  "promoted_until" => {
                    "from" => "2018-04-19T01:59:02+02:00",
                    "to" => nil,
                    "include_lower" => true,
                    "include_upper" => true,
                    "boost" => 1.0
                  }
                }
              },
              "weight" => 1.1
            }
          ],
          "score_mode" => "multiply",
          "boost_mode" => "sum",
          "max_boost" => 3.4028235E+38,
          "boost" => 1.0
        }
      },
      "_source" => false
    }
  end
end
