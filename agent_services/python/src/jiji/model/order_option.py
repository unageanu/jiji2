
class OrderOption():
    def __init__(self, lower_bound, upper_bound, stop_loss, \
        take_profit, trailing_stop, price, expiry):
        self.lower_bound = lower_bound
        self.upper_bound = upper_bound
        self.stop_loss = stop_loss
        self.take_profit = take_profit
        self.trailing_stop = trailing_stop
        self.price = price
        self.expiry = expiry

    def __eq__(self, other):
        return self.lower_bound == other.lower_bound \
           and self.upper_bound == other.upper_bound \
           and self.stop_loss == other.stop_loss \
           and self.take_profit == other.take_profit \
           and self.trailing_stop == other.trailing_stop \
           and self.price == other.price \
           and self.expiry == other.expiry
