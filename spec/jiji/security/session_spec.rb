# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/security/session'
require 'date'

describe Jiji::Security::Session do

  example "ランダムなトークンが生成される" do
    s1 = Jiji::Security::Session.new( DateTime.new(2000,1,1) )
    s2 = Jiji::Security::Session.new( DateTime.new(2000,1,1) )
    expect(s1.token).not_to be_nil
    expect(s1.token).not_to eq(s2.token)
  end

  example "有効期限" do
    s1 = Jiji::Security::Session.new( DateTime.new(2000,1,10) )
    
    expect(s1.expired?( DateTime.new(2000,1,9 ) )).to be false
    expect(s1.expired?( DateTime.new(2000,1,10) )).to be false
    expect(s1.expired?( DateTime.new(2000,1,11) )).to be true
  end
  

end