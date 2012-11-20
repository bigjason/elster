require "stringio"
require "json"

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

  def test_nested_object
    json.key(:person) do
      json.key(:name, "Bobert")
      json.key(:age, 55)
    end
    json.close

    assert_equal "Bobert", parsed["person"]["name"]
  end

  def test_deep_nested_object
    json.key(:person) do
      json.key(:name) do
        json.key(:first, "Bobert")
      end
    end
    json.close

    assert_equal "Bobert", parsed["person"]["name"]["first"]
  end

  def test_nested_array_in_object
    json.key(:children) do
      json.add(1)
      json.add(2)
    end
    json.close

    assert_equal [1,2], parsed["children"]
  end

  def test_nested_object_in_array
    json.add do
      json.key(:child) do
        json.key(:name, "Bobertson")
      end
    end
    json.close

    assert_equal "Bobertson", parsed[0]["child"]["name"]
  end

  def test_array_nested_object
    json.add do
      json.key(:name, "Bobert")
    end
    json.add do
      json.key(:age, 44)
    end
    json.close

    assert_equal "Bobert", parsed[0]["name"]
    assert_equal 44, parsed[1]["age"]
  end

  def test_array_nested_array
    json.add("99")
    json.add do
      json.add(1)
      json.add(2)
    end
    json.add(99)
    json.close

    assert_equal "99", parsed[0]
    assert_equal [1, 2], parsed[1]
    assert_equal 99, parsed[2]
  end

  def test_array_of_nils
    json.add
    json.add
    json.add(nil)
    json.close

    assert_equal [nil, nil, nil], parsed
  end

  def test_object_of_nils
    json.key(:name)
    json.key(:age)
    json.close

    assert_equal({"name" => nil, "age" => nil}, parsed)
  end

  def test_ruby_hash
    json.key("name", {:first => "Bobert", :age => 99})
    json.close

    assert_equal "Bobert", parsed["name"]["first"]
    assert_equal 99, parsed["name"]["age"]
  end

  def test_ruby_array
    json.key("an_array", [1, 2])
    json.close

    assert_equal [1, 2], parsed["an_array"]
  end

  def test_string_with_cr
    json.key("description", "I am \nmulti\nlined")
    json.close

    assert_equal "I am \nmulti\nlined", parsed["description"]
  end

  def test_string_with_cr_at_end
    json.key("description", "I am \n")
    json.close

    assert_equal "I am \n", parsed["description"]
  end

  def test_boolean_true
    json.key("works", true)
    json.close

    assert_equal true, parsed["works"]
  end

  def test_boolean_false
    json.key("no_works", false)
    json.close

    assert_equal false, parsed["no_works"]
  end

  def test_encode_basic_chars
    expected = " !\#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz{|}~"
    json.key("chars", expected)
    json.close

    assert_equal expected, parsed["chars"]
  end

  def test_no_key_in_arrays
    json.add(1)
    assert_raises(Elster::JsonContainerTypeError) do
      json.key("DoesntMatter", "Nothing Written")
    end
  end

  def test_no_add_in_objects
    json.key("DoesntMatter", "Nothing will be written")
    assert_raises(Elster::JsonContainerTypeError) do
      json.add(1)
    end
  end

  def test_valid_when_block_exception
    begin
      json.key "person" do
        json.add "A value"
        raise "An error"
      end
    rescue
      # Nothing to do
    end
    json.key "people", 11
    json.close

    assert_equal 11, parsed["people"]
  end

  def test_valid_when_block_writes_nothing
    json.key :empty do
    end
    json.close

    assert_equal nil, parsed.fetch("empty")
  end

  def test_valid_when_block_writes_nothing_multiple_values
    json.key :empty do
    end
    json.key :value, 1
    json.close

    assert_equal nil, parsed.fetch("empty")
    assert_equal 1, parsed.fetch("value")
  end

  def test_valid_when_block_writes_nothing_multi_values_before_and_after
    json.key :first_value, false
    json.key :empty do
    end
    json.key :value, 1
    json.close

    assert_equal nil, parsed.fetch("empty")
    assert_equal 1, parsed.fetch("value")
    assert_equal false, parsed["first_value"]
  end
end
