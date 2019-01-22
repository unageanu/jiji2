# frozen_string_literal: true

require 'jiji/test/test_configuration'
require 'jiji/model/securities/securities_factory'
require 'jiji/test/mock/mock_securities'

describe Jiji::Model::Securities::SecuritiesFactory do
  before(:example) do
    @factory = Jiji::Model::Securities::SecuritiesFactory.new
    Jiji::Test::Mock::MockSecurities.register_securities_to @factory
  end

  after(:example) do
  end

  it '利用可能な証券会社の一覧を取得できる' do
    securities = @factory.available_securities
    expect(securities).to eq([{
      id:                       :OANDA_JAPAN,
      display_name:             'OANDA Japan',
      configuration_definition: [
        { id: :access_token, description: 'アクセストークン' }
      ]
    }, {
      id:                       :OANDA_JAPAN_DEMO,
      display_name:             'OANDA Japan DEMO',
      configuration_definition: [
        { id: :access_token, description: 'アクセストークン' }
      ]
    }, {
      id:                       :MOCK,
      display_name:             'モック',
      configuration_definition: []
    }, {
      id:                       :MOCK2,
      display_name:             'モック2',
      configuration_definition: []
    }])
  end

  describe 'get' do
    it 'idを指定して、証券会社の情報を取得できる' do
      info = @factory.get(:OANDA_JAPAN)
      expect(info).to eq({
        id:                       :OANDA_JAPAN,
        display_name:             'OANDA Japan',
        configuration_definition: [
          { id: :access_token, description: 'アクセストークン' }
        ]
      })
    end
    it '対応する証券会社がない場合、エラーになる' do
      expect do
        @factory.get(:not_found)
      end.to raise_exception(Jiji::Errors::NotFoundException)
    end
  end

  describe 'create' do
    it 'idを指定して、インスタンスを生成できる' do
      securities = @factory.create(:MOCK, { aa: 'bb' })
      expect(securities).not_to be nil
      expect(securities.config[:aa]).to eq 'bb'
    end
    it '対応する証券会社がない場合、エラーになる' do
      expect do
        @factory.create(:not_found)
      end.to raise_exception(Jiji::Errors::NotFoundException)
    end
  end
end
