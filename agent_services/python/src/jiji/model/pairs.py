
class Pair():
    def __init__(self, name, internal_id, pip, \
        max_trade_units, precision, margin_rate):
        self.name            = name
        self.internal_id     = internal_id
        self.pip             = pip
        self.max_trade_units = max_trade_units
        self.precision       = precision
        self.margin_rate     = margin_rate

    def __eq__(self, other):
        return self.name            == other.name \
           and self.internal_id     == other.internal_id \
           and self.pip             == other.pip \
           and self.max_trade_units == other.max_trade_units \
           and self.precision       == other.precision \
           and self.margin_rate     == other.margin_rate
