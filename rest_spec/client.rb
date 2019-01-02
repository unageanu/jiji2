# coding: utf-8

require 'httpclient'
require 'singleton'
require 'fileutils'

module Jiji
  class Client

    include Singleton

    attr_accessor :token
    attr_accessor :transport

    def initialize(transport = MessagePackTransport.new)
      @api_url          = 'http://127.0.0.1:3000/api'
      @client           = HTTPClient.new
      @transport        = transport
      @client.debug_dev = debug_device
      @token            = nil
    end

    def transport=(transport)
      @transport        = transport

      @client.debug_dev.close if @client.debug_dev
      @client.debug_dev = debug_device
    end

    def wait_for_server_start_up
      puts 'wait for server start up.'
      loop do
        begin
          get('/version')
          return
        rescue Errno::ECONNREFUSED
          puts ' sleep 5 seconds...'
          sleep 5
        end
      end
    end

    [:get, :delete, :options].each do |m|
      define_method(m) do |path, query = nil, header = {}|
        do_request(m, path, nil, query,  header)
      end
    end

    [:post, :put].each do |m|
      define_method(m) do |path, body, header = {}|
        do_request(m, path, body, nil, header)
      end
    end

    def download_csv(path, query = nil, header = {})
      r = @client.request(:get, "#{@api_url}/#{path}", {
        header: complement_header(header),
        query:  query
      })
      Response.new(r, RawTransport.new)
    end

    def post_file(path, file, header = {})
      r = File.open(file) do |io|
        header = complement_header(header)
        header.delete 'Content-Type'
        @client.post("#{@api_url}/#{path}", {
          body:   { 'file' => io },
          header: header
        })
      end
      Response.new(r, @transport)
    end

    def do_request(method, path, body = nil, query = nil, header = {})
      r = @client.request(method, "#{@api_url}/#{path}", {
        body:   serialize_body(body),
        header: complement_header(header),
        query:  query
      })
      Response.new(r, @transport)
    end

    private

    def serialize_body(body)
      body ? @transport.serialize(body) : nil
    end

    def complement_header(header)
      header['Accept']        = @transport.content_type
      header['Content-Type']  = @transport.content_type
      header['Authorization'] = "X-JIJI-AUTHENTICATE #{@token}" if @token
      header
    end

    def debug_device
      log_dir  = File.join(BUILD_DIR, 'rest_spec')
      log_file = "access_#{@transport.name}.log"

      FileUtils.mkdir_p log_dir
      File.open(File.join(log_dir, log_file), 'w')
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

      def name
        'msgpack'
      end

    end

    class JsonTransport < Transport

      def serialize(body)
        JSON.generate(body)
      end

      def deserialize(body)
        JSON.parse(body)
      end

      def content_type
        'application/json'
      end

      def name
        'json'
      end

    end

    class RawTransport < Transport

      def deserialize(body)
        body
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
