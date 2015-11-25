# coding: utf-8

require 'client'

describe 'パスワードの再設定' do
  before(:example) do
    @client = Jiji::Client.instance
  end

  it 'パスワードを変更できる' do
    r = nil
    do_request_using(nil) do
      r = @client.post('settings/password-resetter', {
        'mail_address' => 'foo2@var.com'
      })
      expect(r.status).to eq 204
    end

    r = @client.get('testing/mail')
    expect(r.status).to eq 200
    expect(r.body.length).to eq 1

    token = r.body[0]['body'].scrub.scan(/トークン\: ([a-zA-Z0-9]+)/)[0][0]

    do_request_using(nil) do
      r = @client.put('settings/password-resetter', {
        'token'    => token,
        'password' => 'foo'
      })
      expect(r.status).to eq 200
      expect(r.body['token']).not_to be nil
    end

    @client.token = r.body['token']
  end

  it 'メールアドレスが一致しない場合、エラーになる' do
    do_request_using(nil) do
      r = @client.post('settings/password-resetter', {
        'mail_address' => 'missmatch@var.com'
      })
      expect(r.status).to eq 400
    end
  end

  it '存在しないトークンを指定した場合、エラーになる' do
    do_request_using(nil) do
      r = @client.put('settings/password-resetter', {
        'token'    => 'unknown',
        'password' => 'foo'
      })
      expect(r.status).to eq 400
    end
  end

  def do_request_using(token, &block)
    bak = @client.token
    @client.token = token
    yield
    @client.token = bak
  end
end
