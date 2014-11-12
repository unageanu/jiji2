# coding: utf-8

require 'jiji/composing/container_factory'

describe Jiji::Security::Authenticator do
  
  before(:all) do
    @data_builder = Jiji::Test::DataBuilder.new
    #@data_builder.new_setting(:password, {:password=>})
    
    @container = Jiji::Composing::ContainerFactory.instance.new_container
    
    @authenticator = @container.lookup(:authenticator)
    @store         = @container.lookup(:session_store)
    @time_source   = @container.lookup(:time_source)
    @setting       = @container.lookup(:security_setting)
    
    @setting.password        = "foo"
    @setting.expiration_days = 10
    
    @time_source.set DateTime.new( 2000, 1, 10 )
  end
  
  after(:all) do
    @data_builder.clean
  end
  
  example "正しいパスワードで認証できる" do
    token = @authenticator.authenticate( @setting.hashed_password )
    
    expect(token).not_to be nil
    expect(@store.valid_token? token).to be true
    
    # 有効期限を過ぎると使えなくなる
    @time_source.set DateTime.new( 2000, 1, 21 )
    expect(@store.valid_token? token).to be false
  end

  example "不正なパスワードはエラー" do
    expect { @authenticator.authenticate( 'x' ) }.to raise_error(Jiji::Errors::AuthFailedException) 
  end
  
end