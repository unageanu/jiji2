# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Model::Settings::SecuritiesSetting do

  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new
    @container    = Jiji::Test::TestContainerFactory.instance.new_container
    @provider     = @container.lookup(:securities_provider)
    @repository   = @container.lookup(:setting_repository)

    @setting      = @repository.securities_setting
  end

  after(:example) do
    @data_builder.clean
  end

  it 'アクティブな証券会社を設定できる' do
    plugin = nil
    @setting.on_setting_changed do |_key, event|
      plugin = event[:value]
    end

    expect(@provider.get.class).to be  Jiji::Test::Mock::MockSecurities

    @setting.set_active_securities(:MOCK,  'a' => 'aa', 'b' => 'bb')

    expect(@provider.get.class).to be Jiji::Test::Mock::MockSecurities
    expect(@provider.get.config).to eq('a' => 'aa', 'b' => 'bb')
    expect(plugin.class).to be Jiji::Test::Mock::MockSecurities
    expect(plugin.config).to eq('a' => 'aa', 'b' => 'bb')

    @setting.set_active_securities(:MOCK2, 'a' => 'aa', 'c' => 'cc')

    expect(@provider.get.class).to eq Jiji::Test::Mock::MockSecurities2
    expect(@provider.get.config).to eq('a' => 'aa', 'c' => 'cc')
    expect(plugin.class).to eq Jiji::Test::Mock::MockSecurities2
    expect(plugin.config).to eq('a' => 'aa', 'c' => 'cc')
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

    @setting    = @repository.securities_setting
    @setting.setup
    expect(@provider.get.class).to eq Jiji::Test::Mock::MockSecurities2
    expect(@provider.get.config).to eq('a' => 'aa', 'c' => 'cc')

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
