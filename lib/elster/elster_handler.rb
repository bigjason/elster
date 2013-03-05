module Elster
  class ElsterHandler
    cattr_accessor :default_format
    self.default_format = Mime::JSON

    def supports_streaming?
      true
    end

    def self.call(template)
      %{
        if defined?(json)
          #{template.source}
        else
          output = StringIO.new
          json = Elster::Streamer.new(output)

          #{template.source}
          json.close
          output.string
        end
      }
    end
  end
end

ActionView::Template.register_template_handler :elster, Elster::ElsterHandler
