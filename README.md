# Elster

[![Build Status](https://travis-ci.org/bigjason/elster.png)](https://travis-ci.org/bigjason/elster)

Elster is a streaming JSON encoder written in pure ruby.

## Installation

Add this line to your application's Gemfile:

    gem 'elster'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install elster

## Usage

``` ruby
output = StringIO.new
json = Elster::Streamer.new(output)
json.key(:name, "George")
json.key(:kids) do
  json.add("Job")
  json.add("Buster")
end
json.close

puts output.string
# {"name":"George","kids":["Job","Buster"]}
```

### With Rails

You can use Elster with rails by naming templates with the `.json.elster`
extension.  When used as a rails template simply reference the implicit `json`
object.  For example:

``` ruby
json.key(:name, "George")
json.key(:kids) do
  json.add("Job")
  json.add("Buster")
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
