# coding: utf-8

require 'client'

describe 'パスワードの再設定' do
  before(:example) do
    @client = Jiji::Client.instance
  end

  it 'PUT /setting/security/passwordでパスワードを変更できる' do
    r = @client.put('/setting/security/password', {
      'old_password' => 'test',
      'password'     => 'test2'
    })
    expect(r.status).to eq 204
  end

  it '古いパスワードが一致しない場合、エラーになる' do
    r = @client.put('/setting/security/password', {
      'old_password' => 'not_match',
      'password'     => 'test3'
    })
    expect(r.status).to eq 401
  end
end
