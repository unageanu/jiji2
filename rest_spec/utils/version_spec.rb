# coding: utf-8

require 'client'

describe 'Version' do
  before(:example) do
    @client = Jiji::Client.instance
  end

  it 'GET /version でバージョンを取得できる' do
    r = @client.get('/version')
    expect(r.status).to eq 200
    expect(r.body['version']).not_to be nil
  end
end
