
class Order():
    def __init__(self, pair_name, sell_or_buy, internal_id, type, last_modified, units, price, expiry, lower_bound, upper_bound, stop_loss, take_profit, trailing_stop):
        self.pair_name = pair_name
        self.sell_or_buy = sell_or_buy
        self.internal_id = internal_id
        self.type = type
        self.last_modified = last_modified
        self.units = units
        self.price = price
        self.expiry = expiry
        self.lower_bound = lower_bound
        self.upper_bound = upper_bound
        self.stop_loss = stop_loss
        self.take_profit = take_profit
        self.trailing_stop = trailing_stop

    def __eq__(self, other):
        return self.pair_name == other.pair_name \
           and self.sell_or_buy == other.sell_or_buy \
           and self.internal_id == other.internal_id \
           and self.type == other.type \
           and self.last_modified == other.last_modified \
           and self.units == other.units \
           and self.price == other.price \
           and self.expiry == other.expiry \
           and self.lower_bound == other.lower_bound \
           and self.upper_bound == other.upper_bound \
           and self.stop_loss == other.stop_loss \
           and self.take_profit == other.take_profit \
           and self.trailing_stop == other.trailing_stop
