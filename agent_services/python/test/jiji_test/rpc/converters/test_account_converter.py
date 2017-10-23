import unittest
from datetime import datetime
from decimal import Decimal
import broker_pb2
from jiji.model.account import Account

from jiji.rpc.converters.account_converter import convert_account_from
from jiji.rpc.converters.primitive_converter import convert_decimal_to

class AccountConverterTest(unittest.TestCase):

    def test_convert_account(self):
        account = broker_pb2.Account(account_id="1", account_currency="JPY",
            balance=convert_decimal_to(10000), profit_or_loss=None,
            margin_used=None, margin_rate=convert_decimal_to("0.04"), updated_at=None)

        self.assertEqual(account.profit_or_loss.value, "")

        converted = convert_account_from(account)
        self.assertEqual(converted.account_id, "1")
        self.assertEqual(converted.account_currency, "JPY")
        self.assertEqual(converted.balance, Decimal("10000"))
        self.assertEqual(converted.profit_or_loss, None)
        self.assertEqual(converted.margin_used, None)
        self.assertEqual(converted.margin_rate, Decimal("0.04"))
        self.assertEqual(converted. updated_at, None)
