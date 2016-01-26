require 'oanda_api'

module Jiji::Model::Securities::Internal::Virtual
  class OrderValidator

    def validate(pair_name, sell_or_buy, units, type, options)
      should_be_positive_numeric('units', units)
      if sell_or_buy != :buy && sell_or_buy != :sell
        raise_request_error(
          "Invalid stopLoss sell_or_buy: value=#{sell_or_buy}")
      end
      validate_type_and_options(type, sell_or_buy, options)
    end

    private

    def validate_type_and_options(type, sell_or_buy, options)
      case type
      when :market then validate_market_order_options(sell_or_buy, options)
      when :limit  then validate_limit_order_options(sell_or_buy, options)
      when :stop   then validate_stop_order_options(sell_or_buy, options)
      when :marketIfTouched then
        validate_market_if_touched_order_options(sell_or_buy, options)
      else raise_request_error("invalid type. type=#{type}")
      end
    end

    def validate_market_order_options(sell_or_buy, options)
      validate_take_profit(options, sell_or_buy)
      validate_stop_loss(options, sell_or_buy)
    end

    def validate_market_if_touched_order_options(sell_or_buy, options)
      validate_price_and_expiry(options)
      validate_take_profit(options, sell_or_buy)
      validate_stop_loss(options, sell_or_buy)
    end

    def validate_limit_order_options(sell_or_buy, options)
      validate_price_and_expiry(options)
      validate_take_profit(options, sell_or_buy)
      validate_stop_loss(options, sell_or_buy)
    end

    def validate_stop_order_options(sell_or_buy, options)
      validate_price_and_expiry(options)
      validate_take_profit(options, sell_or_buy)
      validate_stop_loss(options, sell_or_buy)
    end

    def validate_price_and_expiry(options)
      price = options[:price]
      should_be_not_null('price', price)
      should_be_positive_numeric('price', price)

      expiry = options[:expiry]
      should_be_not_null('expiry', expiry)
      should_be_time('expiry', expiry)
    end

    def validate_take_profit(options, sell_or_buy)
      price = options[:price]
      take_profit = options[:take_profit]
      take_profit = nil if take_profit == 0
      return if take_profit.nil?
      should_be_positive_numeric('take_profit', take_profit)
      return if price.nil?
      if sell_or_buy == :buy ? price > take_profit : price < take_profit
        raise_request_error('Invalid takeProfit error: take_profit is ' \
          "below price. price=#{price} take_profit=#{take_profit}")
      end
    end

    def validate_stop_loss(options, sell_or_buy)
      price = options[:price]
      stop_loss = options[:stop_loss]
      stop_loss = nil if stop_loss == 0
      return if stop_loss.nil?
      should_be_positive_numeric('stop_loss', stop_loss)
      return if price.nil?
      if sell_or_buy == :buy ? price < stop_loss : price > stop_loss
        raise_request_error('Invalid stop_loss error: ' \
          "stop_loss is below price. price=#{price} stop_loss=#{stop_loss}")
      end
    end

    def should_be_not_null(param, value)
      raise_request_error("#{param} must not be nil.") if value.nil?
    end

    def should_be_numeric(param, value)
      unless value.is_a?(Numeric)
        raise_request_error("#{param} is not Numeric.")
      end
    end

    def should_be_positive_numeric(param, value)
      should_be_numeric(param, value)
      if value <= 0
        raise_request_error("#{param} is not positive. value=#{value}")
      end
    end

    def should_be_time(param, value)
      raise_request_error("#{param} is not Time.") unless value.is_a?(Time)
    end

    def raise_request_error(message)
      fail OandaAPI::RequestError, message
    end

  end
end
