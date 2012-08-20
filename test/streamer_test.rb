require "test/unit"
require 'turn'
require "stringio"
require "json"

require "elster"

class StreamerTest < MiniTest::Unit::TestCase
  attr_reader :output, :json

  def setup
    @output = StringIO.new
    @json = Elster::Streamer.new(output)
  end

  def teardown
    @parsed = nil
  end

  def parsed
    @parsed ||= JSON.parse(output.string)
  end

  def test_object_single_value
    json.key(:name, "Bobert")
    json.close

    assert_equal "Bobert", parsed["name"]
  end

  def test_object_multiple_values
    json.key(:first_name, "Bobert")
    json.key(:last_name, "Price")
    json.close

    assert_equal "Bobert", parsed["first_name"]
    assert_equal "Price", parsed["last_name"]
  end

  def test_object_numbers
    json.key(:age, 40)
    json.close

    assert_equal 40, parsed["age"]
  end

  def test_array_muliple
    json.add(1)
    json.add(2)
    json.close

    assert_equal [1,2], parsed
  end

  def test_array_single
    json.add("Hooper")
    json.close

    assert_equal ["Hooper"], parsed
  end
end
