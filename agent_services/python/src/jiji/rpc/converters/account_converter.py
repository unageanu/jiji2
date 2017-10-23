from jiji.model.account import Account
from jiji.rpc.converters.primitive_converter import convert_decimal_from, convert_timestamp_from

def convert_account_from(pb_account):
    if (pb_account == None):
        return None
    return Account(pb_account.account_id, pb_account.account_currency, \
        convert_decimal_from(pb_account.balance), \
        convert_decimal_from(pb_account.profit_or_loss), \
        convert_decimal_from(pb_account.margin_used), \
        convert_decimal_from(pb_account.margin_rate), \
        convert_timestamp_from(pb_account.updated_at))
