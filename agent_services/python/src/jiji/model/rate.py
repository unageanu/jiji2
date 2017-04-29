
class Rate():
    def __init__(self, pair, open, close, high, low, timestamp, volume): # pylint: disable=redefined-builtin
        self.pair = pair
        self.open = open
        self.close = close
        self.high = high
        self.low = low
        self.timestamp = timestamp
        self.volume = volume

    def __eq__(self, other):
        return self.pair == other.pair \
           and self.open == other.open \
           and self.close == other.close \
           and self.high == other.high \
           and self.low == other.low \
           and self.timestamp == other.timestamp \
           and self.volume == other.volume
