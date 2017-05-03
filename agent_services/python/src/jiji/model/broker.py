import broker_pb2

from jiji.services.converters import * # pylint: disable=wildcard-import,unused-wildcard-import

class Broker():

    def __init__(self, instance_id, stub_factory):
        self.instance_id = instance_id
        self.stub = stub_factory.create_broker_stub()

    def get_pairs(self):
        response = self.stub.GetPairs(
            broker_pb2.GetPairsRequest(instance_id=self.instance_id))
        return convert_pairs(response.pairs)

    def get_tick(self):
        response = self.stub.GetTick(
            broker_pb2.GetTickRequest(instance_id=self.instance_id))
        return convert_tick(response)

    def retrieve_rates(self, pair_name, interval, start_time, end_time):
        request = broker_pb2.RetrieveRatesRequest(
            instance_id=self.instance_id,
            pair_name=pair_name, interval=interval,
            start_time=convert_timestamp_to(start_time),
            end_time=convert_timestamp_to(end_time))
        rates = self.stub.RetrieveRates(request)
        return convert_rates(rates.rates)

    def get_account(self):
        response = self.stub.GetAccount(
            broker_pb2.GetAccountRequest(instance_id=self.instance_id))
        return convert_account(response)
