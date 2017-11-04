require "spec_helper"
require "json"

RSpec.describe Rack::Inflater do
  def post(input, encoding)
    mock_request = Rack::MockRequest.env_for(
      "/",
      method: "POST",
      input: input,
      "HTTP_CONTENT_ENCODING" => encoding
    )

    JSON.parse(middleware.call(mock_request)[2])
  end

  let(:middleware) do
    Rack::Inflater.new(lambda do |env|
      req = Rack::Request.new(env)

      body = JSON.dump(
        body: req.body.read,
        content_encoding: env["HTTP_CONTENT_ENCODING"],
        length: req.content_length.to_i
      )

      [200, {}, body]
    end)
  end

  it "passes through request body without content-encoding" do
    resp = post("hello", nil)

    expect(resp).to eq(
      "body" => "hello",
      "content_encoding" => nil,
      "length" => 5
    )
  end

  shared_examples_for "compressed" do |type|
    it "extracts compressed request body" do
      resp = post(compress("hello"), type)

      expect(resp).to eq(
        "body" => "hello",
        "content_encoding" => nil,
        "length" => 5
      )
    end

    it "sets the correct content length for UTF-8 content" do
      resp = post(compress("你好"), type)

      expect(resp).to eq(
        "body" => "你好",
        "content_encoding" => nil,
        "length" => 6
      )
    end

    it "decompressed rack.input when it's a tmpfile" do
      Tempfile.open("inflater") do |stream|
        stream << compress("hello")
        stream.rewind
        resp = post(stream, type)

        expect(resp).to eq(
          "body" => "hello",
          "content_encoding" => nil,
          "length" => 5
        )
      end
    end
  end

  context "gzip" do
    it_behaves_like "compressed", "gzip"

    def compress(content)
      string_io = StringIO.new

      gz = Zlib::GzipWriter.new(string_io)
      gz.write content
      gz.close

      string_io.string
    end
  end

  context "deflate" do
    it_behaves_like "compressed", "deflate"

    def compress(content)
      stream = Zlib::Deflate.new(Zlib::DEFAULT_COMPRESSION, -Zlib::MAX_WBITS)
      result = stream.deflate(content, Zlib::FINISH)
      stream.close
      result
    end
  end
end
