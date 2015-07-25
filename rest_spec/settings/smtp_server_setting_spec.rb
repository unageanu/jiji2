# coding: utf-8

require 'client'

describe 'SMTPサーバーの設定' do
  before(:example) do
    @client = Jiji::Client.instance
  end

  it 'GET /settings/smtp-server/status　でステータスを取得できる' do
    r = @client.get('/settings/smtp-server/status')
    expect(r.status).to eq 200
    expect(r.body['enable_postmark']).to eq false
  end

  it 'PUT /settings/smtp-server　で設定を変更できる' do
    r = @client.put('/settings/smtp-server', {
      smtp_host: 'test01',
      smtp_port: '80',
      user_name: 'user1',
      password:  'pass1'
    })
    expect(r.status).to eq 204
  end

  it 'GET /settings/smtp-server　で設定を取得できる' do
    r = @client.get('/settings/smtp-server')
    expect(r.status).to eq 200
    expect(r.body['smtp_host']).to eq 'test01'
    expect(r.body['smtp_port']).to eq 80
    expect(r.body['user_name']).to eq 'user1'
    expect(r.body['password']).to eq 'pxxxx'
  end

  it 'POST /settings/smtp-server/test　でテストメールを送信できる' do
    r = @client.post('/settings/smtp-server/test', {
      smtp_host: 'test01',
      smtp_port: '80',
      user_name: 'user1',
      password:  'pass1'
    })
    expect(r.status).to eq 204

    r = @client.post('/settings/smtp-server/test', {
      mail_address: 'foo@var.com'
    })
    expect(r.status).to eq 204
  end
end
