# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Model::Settings::SecuritiesSetting do
  include_context 'use data_builder'
  include_context 'use container'
  let(:repository) { container.lookup(:setting_repository) }
  let(:provider) { container.lookup(:securities_provider) }
  let(:rmt) { container.lookup(:rmt) }

  before(:example) do
    rmt.setup
    @setting      = repository.securities_setting
  end

  after(:example) do
    rmt.tear_down
  end

  describe '#set_active_securities' do
    it 'アクティブな証券会社を設定できる' do
      plugin = nil
      @setting.on_setting_changed do |_key, event|
        plugin = event[:value]
      end

      expect(provider.get.class).to be Jiji::Test::Mock::MockSecurities
      # テスト環境では、初期値はMockになる

      @setting.set_active_securities(:MOCK,  'a' => 'aa', 'b' => 'bb')

      expect(provider.get.class).to be Jiji::Test::Mock::MockSecurities
      expect(provider.get.config).to eq('a' => 'aa', 'b' => 'bb')
      expect(plugin.class).to be Jiji::Test::Mock::MockSecurities
      expect(plugin.config).to eq('a' => 'aa', 'b' => 'bb')

      @setting.set_active_securities(:MOCK2, 'a' => 'aa', 'c' => 'cc')

      expect(provider.get.class).to eq Jiji::Test::Mock::MockSecurities2
      expect(provider.get.config).to eq('a' => 'aa', 'c' => 'cc')
      expect(plugin.class).to eq Jiji::Test::Mock::MockSecurities2
      expect(plugin.config).to eq('a' => 'aa', 'c' => 'cc')
    end
    it '接続確認としてアカウント情報の取得が行われる。取得できない場合、設定は変更されない' do
      @setting.set_active_securities(:MOCK,  'a' => 'aa', 'b' => 'bb')

      expect do
        @setting.set_active_securities(:MOCK2,
          'fail_on_test_connection' => true)
      end.to raise_error(ArgumentError)

      expect(provider.get.class).to be Jiji::Test::Mock::MockSecurities
      expect(provider.get.config).to eq('a' => 'aa', 'b' => 'bb')

      @setting    = repository.securities_setting
      @setting.setup
      expect(provider.get.class).to be Jiji::Test::Mock::MockSecurities
      expect(provider.get.config).to eq('a' => 'aa', 'b' => 'bb')
    end
  end

  it 'プラグインの設定情報を取得できる' do
    @setting.set_active_securities(:MOCK,  'a' => 'aa', 'b' => 'bb')
    @setting.set_active_securities(:MOCK2, 'a' => 'aa', 'c' => 'cc')

    expect(@setting.get_configurations(:MOCK)).to eq('a' => 'aa', 'b' => 'bb')
    expect(@setting.get_configurations(:MOCK2)).to eq('a' => 'aa', 'c' => 'cc')
  end

  it '設定情報を永続化できる' do
    @setting.set_active_securities(:MOCK,  'a' => 'aa', 'b' => 'bb')
    @setting.set_active_securities(:MOCK2, 'a' => 'aa', 'c' => 'cc')

    @setting    = repository.securities_setting
    @setting.setup
    expect(provider.get.class).to eq Jiji::Test::Mock::MockSecurities2
    expect(provider.get.config).to eq('a' => 'aa', 'c' => 'cc')

    @setting.set_active_securities(:MOCK, 'a' => 'aa', 'b' => 'bb')
  end

  context 'プラグインが存在しない場合' do
    it '設定値取得はエラー' do
      expect do
        @setting.get_configurations(:not_found)
      end.to raise_error(Errors::NotFoundException)
    end
    it 'プラグインの設定はエラー' do
      expect do
        @setting.set_active_securities(:not_found, 'a' => 'aa', 'c' => 'cc')
      end.to raise_error(Errors::NotFoundException)
    end
  end
end
