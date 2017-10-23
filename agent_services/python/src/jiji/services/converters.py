from datetime import datetime
from decimal import Decimal
from agent_pb2 import AgentClasses
from primitives_pb2 import Decimal as RpcDcecimal, OptionalString, OptionalUInt32, OptionalUInt64
from broker_pb2 import OrderRequest, Order, Orders
from google.protobuf import timestamp_pb2  # pylint: disable=no-name-in-module

from jiji.model.tick import Tick, Value
from jiji.model.pairs import Pair
from jiji.model.rate import Rate
from jiji.model.account import Account
from jiji.model.order_option import OrderOption
from jiji.model.order import Order

def convert_agent_property_info(property_info):
    return AgentClasses.AgentClass.Property(
        id=property_info.property_id, name=property_info.name,
        default=property_info.default)

def convert_properties(request):
    properties = dict()
    for prop in request.property_settings:
        properties[prop.id] = prop.value
    return properties

def convert_tick(tick):
    values = convert_tick_values(tick.values)
    return Tick(values, convert_timestamp_from(tick.timestamp))

def convert_tick_values(values):
    result = dict()
    for value in values:
        result[value.pair] = convert_tick_value(value)
    return result

def convert_tick_value(value):
    return Value(convert_decimal_from(value.bid), \
        convert_decimal_from(value.ask))

def convert_pairs(pairs):
    values = dict()
    for pair in pairs:
        values[pair.name] = Pair(pair.name, pair.internal_id, \
            convert_decimal_from(pair.pip), \
            pair.max_trade_units, \
            convert_decimal_from(pair.precision), \
            convert_decimal_from(pair.margin_rate))
    return values

def convert_rates(rates):
    return map(convert_rate, rates)

def convert_rate(rate):
    return Rate(rate.pair, convert_tick_value(rate.open), \
        convert_tick_value(rate.close), convert_tick_value(rate.high), \
        convert_tick_value(rate.low), \
        datetime.fromtimestamp(rate.timestamp.seconds), rate.volume)

def convert_order_response(response):
    return map(convert_rate, rates)

def convert_order_options_to(option):
    return OrderRequest.Option(
        lower_bound=convert_decimal_to(option['lower_bound']),
        upper_bound=convert_decimal_to(option['upper_bound']),
        stop_loss=convert_decimal_to(option['stop_loss']),
        take_profit=convert_decimal_to(option['take_profit']),
        trailing_stop=convert_optional_int32_to(option['trailing_stop']),
        price=convert_decimal_to(option['price']),
        expiry=convert_timestamp_to(option['expiry']))

def convert_account(pb_account):
    return Account(pb_account.account_id, pb_account.account_currency, \
        convert_decimal_from(pb_account.balance), \
        convert_decimal_from(pb_account.profit_or_loss), \
        convert_decimal_from(pb_account.margin_used), \
        convert_decimal_from(pb_account.margin_rate), \
        convert_timestamp_from(pb_account.updated_at))
