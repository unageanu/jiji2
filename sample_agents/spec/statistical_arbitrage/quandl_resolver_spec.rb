
# coding: utf-8

require 'sample_agent_test_configuration'
require 'statistical_arbitrage/shared_context'

describe StatisticalArbitrage::QuandlResolver do

  let(:resolver) do
    StatisticalArbitrage::QuandlResolver.new(ENV["QUANDL_API_KEY"])
  end

  describe "#retrieve_rates_from_quandl" do
    it "can retrieve rates" do
      rates = resolver.retrieve_rates_from_quandl(
        Time.utc(2016, 5, 3), :AUDJPY)
      expect(rates.first["date"]).to eq( Date.new( 2016, 5, 3 ) )
      expect(rates.first["rate"]).not_to be nil
      expect(rates.last["date"]).to eq( Date.new( 2014, 5,  4 ) )
      expect(rates.last["rate"]).not_to be nil

      rates = resolver.retrieve_rates_from_quandl(
        Time.utc(2015, 2, 3), :NZDJPY)
      expect(rates.first["date"]).to eq( Date.new( 2015, 2, 3 ) )
      expect(rates.first["rate"]).not_to be nil
      expect(rates.last["date"]).to eq( Date.new( 2013, 2,  3 ) )
      expect(rates.last["rate"]).not_to be nil
    end
  end

  describe "#retrieve_rates" do
    it "can retrieve rates and mearge its." do
      rates = resolver.retrieve_rates(Time.utc(2016, 5, 3), :AUDJPY, :NZDJPY)
      expect(rates.length).to eq 625
      rates.each do |r|
        expect(r[0]).not_to be nil
        expect(r[1]).not_to be nil
      end
    end
  end

  describe "#linner_least_squares" do
    it "can calculate linner least squares" do
      expect(resolver.linner_least_squares([
        [1,1],[2,2],[3,3],[4,4]
      ])).to eq [1, 0]

      expect(resolver.linner_least_squares([
        [1,-1],[2,-2],[3,-3],[4,-4]
      ])).to eq [-1, 0]

      expect(resolver.linner_least_squares([
        [2,1],[3,2],[4,3]
      ])).to eq [1, -1]

      expect(resolver.linner_least_squares([
        [2,2],[3,2],[4,2]
      ])).to eq [0, 2]
    end
  end

  describe "#resolve" do
    it "can resolve cointegration" do
      result = resolver.resolve(Time.utc(2016, 5, 1), :AUDJPY, :NZDJPY)
      expect(result[:slope]).to eq 0.947045303
      expect(result[:mean]).to eq 11.545187433
      expect(result[:sd]).to eq 2.264904541

      result2 = resolver.resolve(Time.utc(2016, 5, 1, 10), :AUDJPY, :NZDJPY)
      expect(result).to be result2

      result = resolver.resolve(Time.utc(2016, 5, 2), :AUDJPY, :NZDJPY)
      expect(result[:slope]).to eq 0.947045615
      expect(result[:mean]).to eq 11.544242294
      expect(result[:sd]).to eq 2.265128531
    end
  end

end
