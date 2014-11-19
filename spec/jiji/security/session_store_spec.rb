# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/composing/container_factory'

describe Jiji::Security::SessionStore do
  
  before do
    @container = Jiji::Composing::ContainerFactory.instance.new_container
    
    @store       = @container.lookup(:session_store)
    @time_source = @container.lookup(:time_source)
  end
  
  example "tokenに対応するセッションがあれば、valid? はtrueを返す" do
    
    @time_source.set( DateTime.new(2000,1,10) ) 
    
    s1 = Jiji::Security::Session.new( DateTime.new(2000,1,11) )
    s2 = Jiji::Security::Session.new( DateTime.new(2000,1,11) )
    s3 = Jiji::Security::Session.new( DateTime.new(2000,1, 9) ) # 有効期限切れ
    
    @store << s1
    @store << s3
    
    expect(@store.valid_token? s1.token).to be true
    expect(@store.valid_token? s2.token).to be false
    expect(@store.valid_token? s3.token).to be false
    
    # 削除すると使えなくなる
    @store.delete s1.token
    expect(@store.valid_token? s1.token).to be false
    
  end

  example "tokenは最大100個まで保持される" do
    
    @time_source.set( DateTime.new(2000,1,10) ) 
    
    sessions = []
    110.times {
      s = Jiji::Security::Session.new( DateTime.new(2000,1,11) )
      @store   << s
      sessions << s
    }
    
    0.upto(9) {|i|
        expect(@store.valid_token?(sessions[i].token)).to be false
    }
    10.upto(109) {|i|
        expect(@store.valid_token?(sessions[i].token)).to be true
    }
  end
  

end