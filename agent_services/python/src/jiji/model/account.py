
class Account():
    def __init__(self, account_id, account_currency, balance, \
        profit_or_loss, margin_used, margin_rate, updated_at):
        self.account_id = account_id
        self.account_currency = account_currency
        self.balance = balance
        self.profit_or_loss = profit_or_loss
        self.margin_used = margin_used
        self.margin_rate = margin_rate
        self.updated_at = updated_at

    def __eq__(self, other):
        return self.account_id == other.account_id \
           and self.account_currency == other.account_currency \
           and self.balance == other.balance \
           and self.profit_or_loss == other.profit_or_loss \
           and self.margin_used == other.margin_used \
           and self.margin_rate == other.margin_rate \
           and self.updated_at == other.updated_at
