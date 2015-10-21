# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Model::Settings::PairSetting do
  include_context 'use data_builder'
  include_context 'use container'
  let(:repository) { container.lookup(:setting_repository) }
  let(:pairs) { container.lookup(:pairs) }

  before(:example) do
    @setting    = repository.pair_setting
  end

  it '設定がない場合、初期値を返す' do
    expect(@setting.pair_names).to eq []
    expect(@setting.pairs_for_use).to eq [
      pairs.get_by_name(:EURJPY),
      pairs.get_by_name(:USDJPY)
    ]
  end

  it '設定を永続化できる' do
    @setting.pair_names = ['USDJPY']
    expect(@setting.pair_names).to eq ['USDJPY']
    expect(@setting.pairs_for_use).to eq [
      pairs.get_by_name(:USDJPY)
    ]

    @setting.pair_names = %w(USDJPY EURUSD)
    expect(@setting.pair_names).to eq %w(USDJPY EURUSD)
    expect(@setting.pairs_for_use).to eq [
      pairs.get_by_name(:EURUSD),
      pairs.get_by_name(:USDJPY)
    ]

    @setting.save

    expect(@setting.pair_names).to eq %w(USDJPY EURUSD)
    expect(@setting.pairs_for_use).to eq [
      pairs.get_by_name(:EURUSD),
      pairs.get_by_name(:USDJPY)
    ]

    recreate_setting
    expect(@setting.pair_names).to eq %w(USDJPY EURUSD)
    expect(@setting.pairs_for_use).to eq [
      pairs.get_by_name(:EURUSD),
      pairs.get_by_name(:USDJPY)
    ]
  end

  def recreate_setting
    @setting    = repository.pair_setting
  end
end
