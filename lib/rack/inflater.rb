require "rack/inflater/version"
require "rack/inflater/railtie" if defined? ::Rails
require "http_decoders"

module Rack
  class Inflater
    def initialize(app)
      @app = app
    end

    def call(env)
      if decompress?(env)
        character_set = env["rack.input".freeze].external_encoding
        extracted = decode(
          env["rack.input".freeze],
          env["HTTP_CONTENT_ENCODING".freeze]
        )

        env.delete("HTTP_CONTENT_ENCODING".freeze)
        env["CONTENT_LENGTH".freeze] = extracted.bytesize
        input = StringIO.new(extracted).set_encoding(character_set).set_encoding("UTF-8")
        env['rack.input'.freeze] = input
      end

      @app.call(env)
    end

    private

    def decompress?(env)
      method_handled?(env["REQUEST_METHOD".freeze]) &&
        encoding_handled?(env["HTTP_CONTENT_ENCODING".freeze])
    end

    def method_handled?(method)
      %w[POST PUT PATCH DELETE].include? method
    end

    def encoding_handled?(encoding)
      HttpDecoders.accepted_encodings.include? encoding
    end

    def decode(input, content_encoding)
      decompressed = "".force_encoding("ASCII-8BIT")
      decoder = HttpDecoders.decoder_for_encoding(content_encoding).new do |data|
        decompressed << data
      end
      decoder << input.read
      decoder.finalize!
      decompressed
    end
  end
end
