from datetime import datetime
from decimal import Decimal
from primitives_pb2 import Decimal as RpcDcecimal, OptionalString, OptionalUInt32, OptionalUInt64
from google.protobuf import timestamp_pb2  # pylint: disable=no-name-in-module


def convert_timestamp_from(pb_timestamp):
    return None if (pb_timestamp is None) else datetime.fromtimestamp(pb_timestamp.seconds)

def convert_timestamp_to(timestamp):
    return None if (timestamp is None) else timestamp_pb2.Timestamp(seconds=int(timestamp.timestamp()), nanos=0)


def convert_optional_string_from(pb_optional_string):
    return None if (pb_optional_string is None) else pb_optional_string.value

def convert_optional_string_to(string):
    return None if (string is None) else OptionalString(value=string)


def convert_optional_uint32_from(pb_optional_integer):
    return None if (pb_optional_integer is None) else pb_optional_integer.value

def convert_optional_uint32_to(integer):
    return None if (integer is None) else OptionalUInt32(value=integer)


def convert_optional_uint64_from(pb_optional_integer):
    return None if (pb_optional_integer is None) else pb_optional_integer.value

def convert_optional_uint64_to(integer):
    return None if (integer is None) else OptionalUInt64(value=integer)


def convert_decimal_from(pb_decimal):
    print("--" + str(pb_decimal))
    return None if (pb_decimal is None) else Decimal(pb_decimal.value)

def convert_decimal_to(decimal):
    return None if (decimal is None) else RpcDcecimal(value=str(decimal))
