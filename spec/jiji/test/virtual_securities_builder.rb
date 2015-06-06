
module Jiji::Test
  class VirtualSecuritiesBuilder
    def self.build
      oanda_securities = Jiji::Model::Securities::OandaDemoSecurities.new(
        access_token: ENV['OANDA_API_ACCESS_TOKEN'])
      securities_provider = Jiji::Model::Securities::SecuritiesProvider.new
      securities_provider.set oanda_securities

      repository = Jiji::Model::Trading::TickRepository.new
      repository.securities_provider = securities_provider

      Jiji::Model::Securities::VirtualSecurities.new(repository, {
        start_time: Time.utc(2015, 5, 1),
        end_time:   Time.utc(2015, 5, 1, 1),
        pairs:      [
          Jiji::Model::Trading::Pair.new(
            :EURJPY, 'EUR_JPY', 0.01,   10_000_000, 0.001,   0.04),
          Jiji::Model::Trading::Pair.new(
            :USDJPY, 'USD_JPY', 0.01,   10_000_000, 0.001,   0.04)
        ]
      })
    end
  end
end
