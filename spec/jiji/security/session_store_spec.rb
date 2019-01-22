# frozen_string_literal: true

require 'jiji/test/test_configuration'

describe Jiji::Security::SessionStore do
  include_context 'use container'

  let(:session_store) { container.lookup(:session_store) }
  let(:time_source)   { container.lookup(:time_source) }

  it 'tokenに対応するセッションがあれば、valid? はtrueを返す' do
    time_source.set(Time.utc(2000, 1, 10))

    s1 = Jiji::Security::Session.new(Time.utc(2000, 1, 11))
    s2 = Jiji::Security::Session.new(Time.utc(2000, 1, 11))
    s3 = Jiji::Security::Session.new(Time.utc(2000, 1, 9)) # 有効期限切れ

    session_store << s1
    session_store << s3

    expect(session_store.valid_token?(s1.token)).to be true
    expect(session_store.valid_token?(s2.token)).to be false
    expect(session_store.valid_token?(s3.token)).to be false

    # 削除すると使えなくなる
    session_store.invalidate s1.token
    expect(session_store.valid_token?(s1.token)).to be false
  end

  it 'tokenは最大100個まで保持される' do
    time_source.set(Time.utc(2000, 1, 10))

    sessions = []
    110.times do
      s = Jiji::Security::Session.new(Time.utc(2000, 1, 11))
      session_store << s
      sessions << s
    end

    0.upto(9) do |i|
      expect(session_store.valid_token?(sessions[i].token)).to be false
    end
    10.upto(109) do |i|
      expect(session_store.valid_token?(sessions[i].token)).to be true
    end
  end
end
