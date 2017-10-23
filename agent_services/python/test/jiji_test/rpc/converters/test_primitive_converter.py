import unittest
from decimal import Decimal
from datetime import datetime

from jiji.rpc.converters.primitive_converter import * # pylint: disable=wildcard-import,unused-wildcard-import

class PrimitiveConverterTest(unittest.TestCase):

    def test_convert_timestamp(self):
        self.assert_convert_timestamp(datetime.fromtimestamp(1000))
        self.assert_convert_timestamp(None)

    def assert_convert_timestamp(self, value):
        pb_timestamp = convert_timestamp_to(value)
        self.assertEqual(convert_timestamp_from(pb_timestamp), value)

    def test_convert_optional_string(self):
        self.assert_convert_optional_string("aaa")
        self.assert_convert_optional_string(None)

    def assert_convert_optional_string(self, value):
        pb_optional_string = convert_optional_string_to(value)
        self.assertEqual(convert_optional_string_from(pb_optional_string), value)

    def test_convert_optional_uint32(self):
        self.assert_convert_optional_uint32(12)
        self.assert_convert_optional_uint32(0)
        self.assert_convert_optional_uint32(None)
        with self.assertRaises(ValueError):
            convert_optional_uint32_to(-1)

    def assert_convert_optional_uint32(self, value):
        pb_optional_uint32 = convert_optional_uint32_to(value)
        self.assertEqual(convert_optional_uint32_from(pb_optional_uint32), value)

    def test_convert_optional_uint64(self):
        self.assert_convert_optional_uint64(18446744073709551615)
        self.assert_convert_optional_uint64(0)
        self.assert_convert_optional_uint64(None)
        with self.assertRaises(ValueError):
            convert_optional_uint64_to(-1)

    def assert_convert_optional_uint64(self, value):
        pb_optional_uint64 = convert_optional_uint64_to(value)
        self.assertEqual(convert_optional_uint64_from(pb_optional_uint64), value)

    def test_convert_decimal(self):
        self.assert_convert_decimal('4')
        self.assert_convert_decimal('0.4')
        self.assert_convert_decimal('0.04')
        self.assert_convert_decimal('0.004')
        self.assert_convert_decimal('40')
        self.assert_convert_decimal('-4')
        self.assert_convert_decimal('-0.4')
        self.assert_convert_decimal('-0.04')
        self.assert_convert_decimal('-0.004')
        self.assert_convert_decimal('1234.56789')
        self.assert_convert_decimal('-12345678.9')
        self.assert_convert_decimal('1234567890000')
        self.assert_convert_decimal('NaN')
        self.assert_convert_decimal('0')
        self.assert_convert_decimal('-0')
        self.assert_convert_decimal('Infinity')
        self.assert_convert_decimal('-Infinity')
        self.assert_convert_decimal(4)
        self.assert_convert_decimal(1.333)
        self.assert_convert_decimal(0)
        self.assert_convert_decimal(None)

    def assert_convert_decimal(self, value):
        pb_decimal = convert_decimal_to(value)
        self.assertEqual(str(convert_decimal_from(pb_decimal)), str(value))
