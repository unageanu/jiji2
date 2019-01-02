# frozen_string_literal: true

module Jiji::Web::Helpers
  module RequestParameterReader
    include Jiji::Errors

    def load_body
      if %r{^application/x-msgpack}.match?(request.env['CONTENT_TYPE'])
        MessagePack.unpack(request.body.string)
      else
        JSON.parse(request.body.string)
      end
    end

    def read_integer_from(source, key = 'id', nullable = false)
      return nullable ? nil : not_nil(key) if source[key].nil?

      source[key].to_i
    end

    def read_id_from(source, key = 'id', nullable = false)
      return nullable ? nil : not_nil(key) if source[key].nil?

      BSON::ObjectId.from_string(source[key])
    end

    def read_backtest_id_from(source, key = 'backtest_id', nullable = false)
      id = source[key]
      return nullable ? nil : not_nil(key) if id.nil? || id.empty?

      id == 'rmt' ? nil : BSON::ObjectId.from_string(id)
    end

    def read_time_from(source, key, nullable = false)
      return nullable ? nil : not_nil(key) if source[key].nil?

      Time.parse(source[key])
    end

    def read_sort_order_from(source,
      order_key = 'order', direction_key = 'direction', nullable = false)
      return nullable ? nil : not_nil(order_key) if source[order_key].nil?

      {
        source[order_key].to_sym => (source[direction_key] || :asc).to_sym
      }
    end

    private

    def not_nil(key)
      illegal_argument("illegal argument. key=#{key}")
    end
  end
end
