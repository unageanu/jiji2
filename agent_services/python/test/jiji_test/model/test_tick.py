import unittest
from datetime import datetime

from jiji.model.tick import Tick, Value

class TickTest(unittest.TestCase):

    def test_tick(self):

        tick = Tick({
            "USDJPY": Value(112, 112.3),
            "EURJPY": Value(122, 122.3)
        }, datetime(2017, 1, 1, 2, 15, 3))

        self.assertEqual(tick["USDJPY"], Value(112, 112.3))
        self.assertEqual(tick["EURJPY"], Value(122, 122.3))
        self.assertEqual(tick.timestamp, datetime(2017, 1, 1, 2, 15, 3))
        self.assertEqual(len(tick), 2)

    def test_tick_value(self):
        value = Value(112, 112.3)
        self.assertEqual(value.bid, 112)
        self.assertEqual(value.ask, 112.3)
