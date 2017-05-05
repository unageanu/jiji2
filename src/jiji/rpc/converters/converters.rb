# coding: utf-8

require 'grpc'
require 'broker_pb'
require 'broker_services_pb'
require 'logging_pb'
require 'logging_services_pb'
require 'primitives_pb'

require 'jiji/rpc/converters/order_converter'
require 'jiji/rpc/converters/pair_converter'
require 'jiji/rpc/converters/position_converter'
require 'jiji/rpc/converters/primitive_converter'
require 'jiji/rpc/converters/rate_converter'
require 'jiji/rpc/converters/tick_converter'
require 'jiji/rpc/converters/account_converter'

module Jiji::Rpc
  module Converters
    include Jiji::Rpc
    include Jiji::Rpc::Converters::OrderConverter
    include Jiji::Rpc::Converters::PairConverter
    include Jiji::Rpc::Converters::PositionConverter
    include Jiji::Rpc::Converters::PrimitiveConverter
    include Jiji::Rpc::Converters::RateConverter
    include Jiji::Rpc::Converters::TickConverter
    include Jiji::Rpc::Converters::AccountConverter
  end
end
