# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/model/settings/security_setting'

describe Jiji::Model::Settings::MailComposerSetting do
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new

    @container = Jiji::Composing::ContainerFactory.instance.new_container
    @setting   = @container.lookup(:mail_composer_setting)
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
  end

  def recreate_setting
    @container = Jiji::Composing::ContainerFactory.instance.new_container
    @container.lookup(:security_setting)
  end
end
