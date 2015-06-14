# coding: utf-8

require 'client'

describe 'Echo' do
  before(:example) do
    @client = Jiji::Client.instance
  end

  it 'GET /echo を実行できる' do
    r = @client.get('/echo')
    expect(r.status).to eq 200
    expect(r.body['message']).not_to be nil
  end

  it 'OPTIONS /echo を実行できる' do
    r = @client.options('/echo')
    expect(r.status).to eq 200
    expect(r.header['Allow']).to eq(['GET,OPTIONS'])
  end
end
