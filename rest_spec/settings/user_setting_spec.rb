# coding: utf-8

require 'client'

describe 'ユーザー情報の設定' do
  before(:example) do
    @client = Jiji::Client.instance
  end

  it 'PUT /setting/user/password　でパスワードを変更できる' do
    r = @client.put('/setting/user/password', {
      'old_password' => 'test',
      'password'     => 'test2'
    })
    expect(r.status).to eq 204
  end

  it '古いパスワードが一致しない場合、エラーになる' do
    r = @client.put('/setting/user/password', {
      'old_password' => 'not_match',
      'password'     => 'test3'
    })
    expect(r.status).to eq 401
  end

  it 'PUT /setting/user/mail_address　でメールアドレスを変更できる' do
    r = @client.put('/setting/user/mailaddress', {
      'mail_address' => 'foo2@var.com'
    })
    expect(r.status).to eq 204
  end

  it 'メールアドレスが不正な場合、エラーになる' do
    r = @client.put('/setting/user/mailaddress', {
      'mail_address' => ''
    })
    expect(r.status).to eq 400
  end
end
