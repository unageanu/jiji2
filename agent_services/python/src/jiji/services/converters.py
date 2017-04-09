from datetime import datetime
import agent_pb2
import agent_pb2_grpc
from google.protobuf import empty_pb2 # pylint: disable=no-name-in-module
from google.protobuf.timestamp_pb2 import Timestamp

from jiji.model.tick import Tick, Value
from jiji.model.pairs import Pair
from jiji.model.rate import Rate

def convert_agent_property_info(property_info):
    return agent_pb2.AgentClasses.AgentClass.Property(
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
    return Value(value.bid, value.ask)

def convert_pairs(pairs):
    values = dict()
    for pair in pairs:
        values[pair.name] = Pair(pair.name, pair.internal_id, pair.pip, \
            pair.max_trade_units, pair.precision, pair.margin_rate)
    return values

def convert_rates(rates):
    return map(convert_rate, rates)

def convert_rate(rate):
    return Rate(rate.pair, convert_tick_value(rate.open), \
        convert_tick_value(rate.close), convert_tick_value(rate.high), \
        convert_tick_value(rate.low), \
        datetime.fromtimestamp(rate.timestamp.seconds), rate.volume)

def convert_timestamp_from(pb_timestamp):
    return datetime.fromtimestamp(pb_timestamp.seconds)

def convert_timestamp_to(timestamp):
    return Timestamp(seconds=int(timestamp.timestamp()), nanos=0)
