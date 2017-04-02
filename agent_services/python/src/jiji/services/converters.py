from datetime import datetime
import agent_pb2
import agent_pb2_grpc
from google.protobuf import empty_pb2 # pylint: disable=no-name-in-module

from jiji.model.tick import Tick, Value
from jiji.model.pairs import Pair, Pairs

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
    values = convert_tick_value(tick.values)
    return Tick(values, datetime.fromtimestamp(tick.timestamp.seconds))

def convert_tick_value(values):
    result = dict()
    for value in values:
        result[value.pair] = Value(value.bid, value.ask)
    return result

def convert_pairs(pairs):
    values = dict()
    for pair in pairs:
        values[pair.name] = Pair(pair.name, pair.internal_id, pair.pip, \
            pair.max_trade_units, pair.precision, pair.margin_rate)
    return Pairs(values)
