# coding: utf-8

require 'httpclient'
require 'singleton'

module Jiji
  class Client

    include Singleton

    attr_writer :token
    attr_writer :transport

    def initialize(transport = MessagePackTransport.new)
      @api_url          = 'http://localhost:5000/api'
      @client           = HTTPClient.new
      @client.debug_dev = debug_device
      @transport        = transport
      @token            = nil
    end

    def get(path, query = nil, header = {})
      r = @client.get("#{@api_url}/#{path}",
        query, complement_header(header))
      Response.new(r, @transport)
    end

    def post(path, body, header = {})
      r = @client.post("#{@api_url}/#{path}",
        serialize_body(body), complement_header(header))
      Response.new(r, @transport)
    end

    def put(path, body, header = {})
      r = @client.put("#{@api_url}/#{path}",
        serialize_body(body), complement_header(header))
      Response.new(r, @transport)
    end

    def delete(path, header = {})
      r = @client.delete("#{@api_url}/#{path}",
        complement_header(header))
      Response.new(r, @transport)
    end

    private

    def serialize_body(body)
      @transport.serialize(body)
    end

    def complement_header(header)
      header['Accept']        = @transport.content_type
      header['Content-Type']  = @transport.content_type
      header['Authorization'] = "X-JIJI-AUTHENTICATE #{@token}" if @token
      header
    end

    def debug_device
      log_dir = File.join(BUILD_DIR, 'rest_spec')
      File.open(File.join(log_dir, 'access.log'), 'w')
    end

    class Transport

    end

    class MessagePackTransport < Transport

      def serialize(body)
        MessagePack.pack(body)
      end

      def deserialize(body)
        MessagePack.unpack(body)
      end

      def content_type
        'application/x-msgpack'
      end

    end

    class JsonTransport < Transport

      def serialize
        JSON.generate(body)
      end

      def deserialize(body)
        JSON.parse(body)
      end

      def content_type
        'application/json'
      end

    end

    class Response

      attr_reader :raw

      def initialize(raw_response, transport)
        @raw       = raw_response
        @transport = transport
      end

      def body
        @transport.deserialize(@raw.body)
      end

      def header
        @raw.header
      end

      def status
        @raw.status
      end

    end

  end
end
