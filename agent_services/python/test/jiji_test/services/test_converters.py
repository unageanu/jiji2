import unittest
from decimal import Decimal

from jiji.services.converters import convert_decimal_from, convert_decimal_to

class ConvertersTest(unittest.TestCase):

    def test_convert_decimal_to(self):
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

    def assert_convert_decimal(self, value):
        pb_decimal = convert_decimal_to(Decimal(value))
        self.assertEqual(str(convert_decimal_from(pb_decimal)), value)
