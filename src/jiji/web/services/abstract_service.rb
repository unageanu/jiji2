# coding: utf-8

require 'encase'
require 'json'
require 'msgpack'
require 'time'
require 'jiji/web/middlewares/base'
require 'jiji/web/middlewares/authentication_filter'
require 'jiji/web/middlewares/security_filter'
require 'jiji/web/transport/json'
require 'jiji/web/transport/messagepack'

module Jiji::Web
  class AbstractService < Base

    include Jiji::Errors

    use Rack::Deflater
    use Sinatra::CommonLogger
    use SecurityFilter
    use AllowCrossDomainRequestFilter

    set :sessions, false

    private

    def load_body
      if request.env['CONTENT_TYPE'] =~ %r{^application/x-msgpack}
        MessagePack.unpack(request.body)
      else
        JSON.load(request.body)
      end
    end

    def get_time_from_query_param(key)
      illegal_argument("illegal argument. key=#{key}") if request[key].nil?
      Time.parse(request[key])
    end

    def get_sort_order_from_query_param(
      order_key = 'order', direction_key = 'direction')
      return nil unless request[order_key]
      {
        request[order_key].to_sym => request[direction_key].to_sym || :asc
      }
    end

    def get_backtest_id_from_path_param(key = 'backtest_id')
      id_str = params[key]
      convert_to_backtest_id(id_str)
    end

    def convert_to_backtest_id(id_str)
      return nil if id_str.nil? || id_str.empty?
      id_str == 'rmt' ? nil : BSON::ObjectId.from_string(id_str)
    end

    def create_id(id)
      BSON::ObjectId.from_string(id)
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

    def invoke_on_rmt_process(&block)
      rmt.process.post_exec(&block).value
    end

    def rmt
      lookup(:rmt)
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

    def allow(allow_methods)
      publish_access_control_allow_header_if_allow_crossdomain(allow_methods)
      headers({
        'Allow' => allow_methods
      })
    end

    def publish_access_control_allow_header_if_allow_crossdomain(allow_methods)
      return unless AllowCrossDomainRequestFilter.allow_cross_domain_request?
      headers({
        'Access-Control-Allow-Headers' =>
          'X-Requested-With, X-HTTP-Method-Override, ' \
          + 'Content-Type, Cache-Control, Accept, Authorization',
        'Access-Control-Allow-Methods' => allow_methods
      })
    end

    def no_cache
      @no_cache ||= {
        'Cache-Control' => 'no-cache, no-store',
        'Expires'       => '-1',
        'Pragma'        => 'no-cache'
      }
    end

    def cacheable
      max_age = 60 * 60 * 24 * 365
      @cacheable ||= {
        'Cache-Control' => "public max_age=#{max_age}",
        'Expires'       => max_age.to_s
      }
    end

  end

  class AuthenticationRequiredService < AbstractService

    use Jiji::Web::AuthenticationFilter

  end
end
