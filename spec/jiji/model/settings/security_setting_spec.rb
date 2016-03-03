# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/model/settings/security_setting'

describe Jiji::Model::Settings::SecuritySetting do
  include_context 'use data_builder'
  include_context 'use container'
  let(:repository) { container.lookup(:setting_repository) }

  before(:example) do
    @setting = repository.security_setting
  end

  it '設定がない場合、初期値を返す' do
    expect(@setting.password_setted?).to be false
    expect(@setting.salt).to be nil
    expect(@setting.hashed_password).to be nil
    expect(@setting.expiration_days).to be 10
    expect(@setting.mail_address).to be nil
  end

  it 'パスワードを設定して永続化できる。saltは自動生成される' do
    @setting.password     = 'aaa'
    @setting.mail_address = 'foo@var.com'

    expect(@setting.password_setted?).to be true
    expect(@setting.salt).not_to be nil
    expect(@setting.hashed_password).not_to be nil

    # パスワードを変更するとsaltは再作成される
    old_salt  = @setting.salt
    old_hash  = @setting.hashed_password

    @setting.password = 'aaa'

    expect(@setting.password_setted?).to be true
    expect(@setting.salt).not_to be old_salt
    expect(@setting.hashed_password).not_to be old_hash

    # 永続化
    salt = @setting.salt
    hash = @setting.hashed_password

    @setting.expiration_days = 12
    @setting.save

    recreate_setting
    expect(@setting.password_setted?).to be true
    expect(@setting.salt).to eq salt
    expect(@setting.hashed_password).to eq hash
    expect(@setting.expiration_days).to eq 12
  end

  it 'メールアドレスを設定して永続化できる' do
    @setting.password     = 'aaa'
    @setting.mail_address = 'foo@var.com'

    expect(@setting.mail_address).to eq 'foo@var.com'

    @setting.save
    recreate_setting

    expect(@setting.mail_address).to eq 'foo@var.com'
  end

  it 'メールアドレスが不正な場合、エラー' do
    @setting.expiration_days = 12

    @setting.mail_address = 'foovar.com'
    expect do
      @setting.save
    end.to raise_exception(ActiveModel::StrictValidationFailed)

    @setting.mail_address = nil
    expect do
      @setting.save
    end.to raise_exception(ActiveModel::StrictValidationFailed)

    @setting.mail_address = ''
    expect do
      @setting.save
    end.to raise_exception(ActiveModel::StrictValidationFailed)
  end

  it 'expiration_days が不正な場合、エラー' do
    @setting.mail_address = 'foo@var.com'

    @setting.expiration_days = -1
    expect do
      @setting.save
    end.to raise_exception(ActiveModel::StrictValidationFailed)

    @setting.expiration_days = nil
    expect do
      @setting.save
    end.to raise_exception(ActiveModel::StrictValidationFailed)

    @setting.expiration_days = ''
    expect do
      @setting.save
    end.to raise_exception(ActiveModel::StrictValidationFailed)
  end

  def recreate_setting
    @setting = repository.security_setting
  end
end
