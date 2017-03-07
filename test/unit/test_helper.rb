require 'simplecov'
require 'pathname'

SimpleCov.use_merging true
SimpleCov.start do
  command_name 'MiniTest'
  add_filter 'test'
end
SimpleCov.root Pathname.new(File.dirname(__FILE__) + "../../../")


require 'minitest/autorun'
require 'minitest/spec'
require "minitest-spec-context"
require "mocha/setup"

require 'grokngelf'

def fixture_log(log_file)
  File.join(File.dirname(__FILE__), "fixtures", log_file)
end

def event_match(expected, actual)
  return true if actual.include_data?(expected)
  puts "Events differ: %s" % Hash[*(expected.to_a - actual.to_hash.to_a).flatten]
  false
end
