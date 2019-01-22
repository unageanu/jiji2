# frozen_string_literal: true

require 'jiji/test/test_configuration'

describe Jiji::Security::Authenticator do
  include_context 'use data_builder'
  include_context 'use container'

  let(:authenticator) { container.lookup(:authenticator) }
  let(:session_store) { container.lookup(:session_store) }
  let(:time_source) { container.lookup(:time_source) }
  let(:setting_repository) { container.lookup(:setting_repository) }

  before(:example) do
    time_source.set Time.utc(2000, 1, 10)

    setting = setting_repository.security_setting
    setting.mail_address    = 'foo@var.com'
    setting.password        = 'foo'
    setting.expiration_days = 10
    setting.save
  end

  it '正しいパスワードで認証できる' do
    token = authenticator.authenticate('foo')

    expect(token).not_to be nil
    expect(session_store.valid_token?(token, :user)).to be true

    # 有効期限を過ぎると使えなくなる
    time_source.set Time.utc(2000, 1, 21)
    expect(session_store.valid_token?(token, :user)).to be false
  end

  it '不正なパスワードはエラー' do
    expect do
      authenticator.authenticate('x')
    end.to raise_error(Jiji::Errors::AuthFailedException)
  end
end
