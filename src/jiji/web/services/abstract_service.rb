# coding: utf-8

require 'encase'
require 'json'
require 'msgpack'
require 'time'
require 'jiji/web/middlewares/base'
require 'jiji/web/middlewares/authentication_filter'
require 'jiji/web/transport/json'
require 'jiji/web/transport/messagepack'

module Jiji::Web
  class AbstractService < Base

    include Jiji::Errors

    use Rack::Deflater

    set :sessions, false

    private

    def load_body
      if request.env['CONTENT_TYPE'] =~ /^application\/x-msgpack/
        MessagePack.unpack(request.body)
      else
        JSON.load(request.body)
      end
    end

    def get_time_from_query_param(key)
      illegal_argument("illegal argument. key=#{key}") if request[key].nil?
      Time.parse(request[key])
    end

    def get_pagenation_query_from_query_param(key)
      illegal_argument("illegal argument. key=#{key}") if request[key].nil?
      Time.parse(request[key])
    end

    def serialize(body)
      if request.accept? 'application/x-msgpack'
        content_type 'application/x-msgpack;charset=UTF-8'
        MessagePack.pack(body)
      else
        content_type 'application/json;charset=UTF-8'
        JSON.generate(body)
      end
    end

    def ok(body)
      [200, no_cache, serialize(body)]
    end

    def created(body)
      [201, serialize(body)]
    end

    def no_content
      [204]
    end

    def no_cache
      @no_cache ||= {
        'Cache-Control' => 'no-cache, no-store',
        'Expires'       => '-1',
        'Pragma'        => 'no-cache'
      }
    end

  end

  class AuthenticationRequiredService < AbstractService

    use Jiji::Web::AuthenticationFilter

  end
end
