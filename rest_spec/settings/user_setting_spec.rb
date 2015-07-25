# coding: utf-8

require 'client'

describe 'ユーザー情報の設定' do
  before(:example) do
    @client = Jiji::Client.instance
  end

  it 'PUT /settings/user/password　でパスワードを変更できる' do
    r = @client.put('/settings/user/password', {
      'old_password' => 'test',
      'password'     => 'test2'
    })
    expect(r.status).to eq 204
  end

  it '古いパスワードが一致しない場合、エラーになる' do
    r = @client.put('/settings/user/password', {
      'old_password' => 'not_match',
      'password'     => 'test3'
    })
    expect(r.status).to eq 401
  end

  it 'PUT /settings/user/mailaddress　でメールアドレスを変更できる' do
    r = @client.put('/settings/user/mailaddress', {
      'mail_address' => 'foo2@var.com'
    })
    expect(r.status).to eq 204
  end

  it 'GET /settings/user/mailaddress　でメールアドレスを取得できる' do
    r = @client.get('/settings/user/mailaddress')
    expect(r.status).to eq 200
    expect(r.body['mail_address']).to eq 'foo2@var.com'
  end

  it 'メールアドレスが不正な場合、エラーになる' do
    r = @client.put('/settings/user/mailaddress', {
      'mail_address' => ''
    })
    expect(r.status).to eq 400
  end
end
