# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/composing/container_factory'

describe Jiji::Security::Authenticator do
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new

    @container = Jiji::Composing::ContainerFactory.instance.new_container

    @authenticator = @container.lookup(:authenticator)
    @store         = @container.lookup(:session_store)
    @time_source   = @container.lookup(:time_source)
    @repository    = @container.lookup(:setting_repository)

    @setting       = @repository.security_setting

    @setting.mail_address    = 'foo@var.com'
    @setting.password        = 'foo'
    @setting.expiration_days = 10
    @setting.save

    @time_source.set Time.utc(2000, 1, 10)
  end

  after(:example) do
    @data_builder.clean
  end

  it '正しいパスワードで認証できる' do
    token = @authenticator.authenticate('foo')

    expect(token).not_to be nil
    expect(@store.valid_token? token, :user).to be true

    # 有効期限を過ぎると使えなくなる
    @time_source.set Time.utc(2000, 1, 21)
    expect(@store.valid_token? token, :user).to be false
  end

  it '不正なパスワードはエラー' do
    expect do
      @authenticator.authenticate('x')
    end.to raise_error(Jiji::Errors::AuthFailedException)
  end
end
