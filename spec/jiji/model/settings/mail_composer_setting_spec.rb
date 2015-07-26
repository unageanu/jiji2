# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/model/settings/security_setting'

describe Jiji::Model::Settings::MailComposerSetting do
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new

    @container = Jiji::Composing::ContainerFactory.instance.new_container
    @repository = @container.lookup(:setting_repository)

    @setting    = @repository.mail_composer_setting
  end

  after(:example) do
    @data_builder.clean
  end

  it '設定がない場合、初期値を返す' do
    expect(@setting.smtp_host).to be nil
    expect(@setting.smtp_port).to be 587
    expect(@setting.user_name).to be nil
    expect(@setting.password).to be nil
  end

  it '設定を永続化できる' do
    @setting.smtp_host = 'smtp.foo.com'
    @setting.smtp_port = 25
    @setting.user_name = 'aaa'
    @setting.password  = 'bbb'

    expect(@setting.smtp_host).to eq 'smtp.foo.com'
    expect(@setting.smtp_port).to be 25
    expect(@setting.user_name).to eq 'aaa'
    expect(@setting.password).to eq 'bbb'

    @setting.save

    expect(@setting.smtp_host).to eq 'smtp.foo.com'
    expect(@setting.smtp_port).to be 25
    expect(@setting.user_name).to eq 'aaa'
    expect(@setting.password).to eq 'bbb'

    recreate_setting
    expect(@setting.smtp_host).to eq 'smtp.foo.com'
    expect(@setting.smtp_port).to be 25
    expect(@setting.user_name).to eq 'aaa'
    expect(@setting.password).to eq 'bbb'

    @setting.smtp_host = ''
    @setting.smtp_port = 25
    @setting.user_name = nil
    @setting.password  = nil

    @setting.save

    expect(@setting.smtp_host).to eq ''
    expect(@setting.smtp_port).to be 25
    expect(@setting.user_name).to eq nil
    expect(@setting.password).to eq nil
  end

  it 'smtp_hostが不正な場合エラーになる' do
    @setting.smtp_host = 'a' * 1001
    expect do
      @setting.save
    end.to raise_exception(ActiveModel::StrictValidationFailed)
  end

  it 'smtp_portが不正な場合エラーになる' do
    @setting.smtp_port = -1
    expect do
      @setting.save
    end.to raise_exception(ActiveModel::StrictValidationFailed)

    @setting.smtp_port = nil
    expect do
      @setting.save
    end.to raise_exception(ActiveModel::StrictValidationFailed)

    @setting.smtp_port = ''
    expect do
      @setting.save
    end.to raise_exception(ActiveModel::StrictValidationFailed)
  end

  it 'user_nameが不正な場合エラーになる' do
    @setting.user_name = 'a' * 1001
    expect do
      @setting.save
    end.to raise_exception(ActiveModel::StrictValidationFailed)
  end

  it 'passwordが不正な場合エラーになる' do
    @setting.password = 'a' * 1001
    expect do
      @setting.save
    end.to raise_exception(ActiveModel::StrictValidationFailed)
  end

  def recreate_setting
    @setting    = @repository.mail_composer_setting
  end
end
