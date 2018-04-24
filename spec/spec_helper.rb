require 'bundler/setup'
require 'fluent/parser'
require 'pry'
require './lib/fluent/plugin/parser_es_slow_query'

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.mock_with :rspec do |c|
    c.syntax = :expect
    c.verify_partial_doubles = true
  end
end
