require "multi_json"

module Elster
  class Streamer
    attr_reader :output

    # Create a new instance of Streamer with the specified output stream. The
    # `output` must respond to `write`.
    def initialize(output)
      @output = output
      # Some mutable state to make Rich Hickey weep.
      @stack = []
      @item_count = 0
    end

    # Close the encoding optionally closing the provided output stream.
    def close(close_stream=false)
      end_section
      if close_stream
        @output.close
      end
    end

    # Output an object key value pair. If a block is passed, the `value` will be
    # ignored and a nested object or array can be added.
    #
    # Example:
    #
    #   json.key(:mistake, "HUGE!")
    #
    #   { "mistake" : "HUGE!" }
    #
    #
    #   json.key(:mistake) do
    #     json.key(:type, "HUGE!")
    #   end
    #
    #   { "mistake" : { "type" : "HUGE!" } }
    #
    #
    #   json.key(:mistake) do
    #     json.add("HUGE!")
    #   end
    #
    #   { "mistake" : [ "HUGE!" ] }
    def key(key, value=nil, &block)
      if @item_count > 0
        write ","
      else
        @current_type = :object
        begin_section
      end

      write encode_value(key)
      write ":"

      if block
        nest_in
        block.call
        nest_out
      else
        write encode_value(value)
      end

      @item_count += 1
    end

    # Output an array. If a block is passes the `value` will be ignored and a nested value
    # started.
    #
    # Example:
    #
    #   json.add(1)
    #   json.add("Ansible")
    #
    #   [ 1, "Ansible" ]
    #
    #   json.add(1)
    #   json.add do
    #     json.set(:name, "Wiggens")
    #   end
    #
    #   [ 1, { "name" : "Wiggens" } ]
    def add(value=nil, &block)
      if @item_count > 0
        write ","
      else
        @current_type = :array
        begin_section
      end

      if block
        nest_in
        block.call
        nest_out
      else
        write encode_value(value)
      end

      @item_count += 1
    end

    protected

    def write(output)
      @output.write(output)
    end

    def encode_value(value)
      case value
      when String
        encode_string(value)
      when Numeric
        encode_number(value)
      when TrueClass
        encode_boolean(value)
      when FalseClass
        encode_boolean(value)
      when nil
        encode_nil(value)
      else
        MultiJson.dump(value)
      end
    end

    def encode_generic(value)
      MultiJson.dump(value)
    end

    SAFE_RE = Regexp.new("\\A[#{Regexp.escape((32..126).select{|c| c != 34}.map{|c| c.chr}.join)}]+\\z")
    def encode_string(value)
      if value =~ SAFE_RE
        "\"#{value}\""
      else
        encode_generic(value.to_s)
      end
    end

    def encode_number(value)
      value.to_s
    end

    def encode_boolean(value)
      if value
        "true"
      else
        "false"
      end
    end

    def encode_nil(value)
      "null"
    end

    def nest_in
      @stack.push([@item_count, @current_type])
      @item_count = 0
      @current_type = nil
    end

    def nest_out
      end_section
      @item_count, @current_type = @stack.pop
    end

    def begin_section
      case @current_type
      when :array
        write("[")
      else
        write("{")
      end
    end

    def end_section
      case @current_type
      when :array
        write("]")
      else
        write("}")
      end
    end
  end
end
