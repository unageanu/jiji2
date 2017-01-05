
class Tick():
    def __init__(self, values, timestamp):
        self.timestamp = timestamp
        self.values = values

    def __getitem__(self, name):
        return self.values[name]

    def __len__(self):
        return len(self.values)

    def items(self):
        return self.values.items()

    def __eq__(self, other):
        return self.timestamp == other.timestamp \
           and self.values == other.values


class Value():
    def __init__(self, bid, ask):
        self.bid = bid
        self.ask = ask

    def __eq__(self, other):
        return self.bid == other.bid \
           and self.ask == other.ask
