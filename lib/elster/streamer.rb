require "stringio"
require "multi_json"

module Elster
  class Streamer
    attr_reader :output

    def initialize(output=StringIO.new)
      @stack = []
      @item_count = 0

      @output = output
    end

    def close(close_stream=false)
      end_section
      if close_stream
        @output.close
      end
    end

    def key(key, value)
      if @item_count > 0
        write ","
      else
        @current_type = :object
        begin_section
      end
      write encode_value(key)
      write ":"
      write encode_value(value)
      @item_count += 1
    end

    def add(value)
      if @item_count > 0
        write ","
      else
        @current_type = :array
        begin_section
      end
      write encode_value(value)
      @item_count += 1
    end

    protected

    def write(output)
      @output.write(output)
    end

    def encode_value(value)
      MultiJson.dump(value)
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
