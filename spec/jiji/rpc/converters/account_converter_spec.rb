# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Rpc::Converters::AccountConverter do
  include_context 'use data_builder'
  include_context 'use container'

  class Converter

    include Jiji::Rpc::Converters

  end

  let(:converter) { Converter.new }
  let(:builder)   { container.lookup(:position_builder) }
  let(:positions) do
    Jiji::Model::Trading::Positions.new([
      data_builder.new_position(1),
      data_builder.new_position(2),
      data_builder.new_position(3)
    ], builder, Jiji::Model::Trading::Account.new(1, 'JPY', 10_000, 0.04))
  end
  Account = Jiji::Model::Trading::Account

  describe '#convert_account_to_pb' do
    it 'converts Account to Rpc::Account' do
      account = Jiji::Model::Trading::Account.new('1', 'JPY', 10_000, 0.04)
      converted = converter.convert_account_to_pb(account)
      expect(converted.account_id).to eq '1'
      expect(converted.account_currency).to eq 'JPY'
      expect(converted.balance).to eq 10_000
      expect(converted.profit_or_loss).to eq 0
      expect(converted.updated_at).to eq nil
      expect(converted.margin_used).to eq 0
      expect(converted.margin_rate.round(2)).to eq 0.04

      account.update(positions, Time.at(100))
      converted = converter.convert_account_to_pb(account)
      expect(converted.account_id).to eq '1'
      expect(converted.account_currency).to eq 'JPY'
      expect(converted.balance).to eq 10_000
      expect(converted.profit_or_loss).to eq -180.0
      expect(converted.updated_at.seconds).to eq 100
      expect(converted.updated_at.nanos).to eq 0
      expect(converted.margin_used.round(1)).to eq 245_604.8
      expect(converted.margin_rate.round(2)).to eq 0.04
    end
    it 'returns nil when an order is nil' do
      converted = converter.convert_account_to_pb(nil)
      expect(converted).to eq nil
    end
  end

end
