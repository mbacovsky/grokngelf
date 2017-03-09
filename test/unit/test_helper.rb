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

def log_event_matcher(expected_log, index=nil)
  LogEventMatcher.new(expected_log, index)
end

class LogEventMatcher < Mocha::ParameterMatchers::Base
  def initialize(expected_log, index=nil)
    @expected_log = expected_log
    @index = index
    @diffs = []
    @counter = 0
  end

  def matches?(actual_parameters)
    @counter += 1
    actual = actual_parameters.shift
    return true if actual.include_data?(@expected_log)
    if @index.nil? or @counter == @index
      diff = @expected_log.keys.inject({}) do |sum, key|
        sum[key] = "- #{@expected_log[key]}, + #{actual.fetch(key)}" unless @expected_log[key] == actual.fetch(key)
        sum
      end
      @diffs << diff
    end
    false
  end

  def mocha_inspect
    "Received events: " + @diffs.map { |d| "\n  - #{d}"}.join('')
  end
end
