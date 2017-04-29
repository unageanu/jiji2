# coding: utf-8

require 'client'
require 'uri'

describe '/agents' do
  before(:example) do
    @client = Jiji::Client.instance
    @data_builder = Jiji::Test::DataBuilder.new
  end

  it '`POST agents/sources` can register python agent source' do
    r = @client.get('agents/sources')
    expect(r.status).to eq 200

    expect(r.body.length).to be >= 3

    r = @client.post('agents/sources', {
      name:     'python_test1',
      memo:     'メモ1',
      type:     :agent,
      language: 'python',
      body:     @data_builder.new_python_agent_body
    })
    expect(r.status).to eq 201

    expect(r.body['id']).not_to be nil
    expect(r.body['error']).to be nil
    expect(r.body['status']).to eq 'normal'
    expect(r.body['name']).to eq 'python_test1'
  end

  it '`GET agents/sources/:id` can get a registerd agent source' do
    r = @client.get('agents/sources')
    expect(r.status).to eq 200

    expect(r.body.length).to be >= 4
    r.body.each do |a|
      expect(a['id']).not_to be nil
      expect(a['status']).not_to be nil
      expect(a['body']).to be nil
    end
  end

  it '`GET agents/classes` can get registerd agent classes' do
    r = @client.get('agents/classes')
    expect(r.status).to eq 200
    expect(r.body.find { |i| i['name'] == 'TestAgent@python_test1' }).to eq({
      'name' => 'TestAgent@python_test1',
      'description' => 'description1',
      'properties' => [
        { 'id' => 'a', 'name' => 'プロパティ1', 'default' => 'aa' },
        { 'id' => 'b', 'name' => 'プロパティ2', 'default' => '' }
      ]
    })
  end

  it '`PUT agents/sources/:id` can update an agent source' do
    r = @client.get('agents/sources')
    id = r.body.find { |a| a['name'] == 'python_test1' }['id']

    r = @client.put("agents/sources/#{id}", {
      body: @data_builder.new_python_agent_body(2)
    })
    expect(r.status).to eq 200
    expect(r.body['id']).not_to be nil
    expect(r.body['error']).to be nil
    expect(r.body['status']).to eq 'normal'
    expect(r.body['name']).to eq 'python_test1'
    expect(r.body['body']).to eq @data_builder.new_python_agent_body(2)

    r = @client.get("agents/sources/#{id}")
    expect(r.status).to eq 200

    expect(r.body['id']).not_to be nil
    expect(r.body['error']).to be nil
    expect(r.body['status']).to eq 'normal'
    expect(r.body['name']).to eq 'python_test1'
    expect(r.body['body']).to eq @data_builder.new_python_agent_body(2)
  end

  it '`PUT /agents/sources/:id` can rename an agent source' do
    r = @client.get('agents/sources')
    id = r.body.find { |a| a['name'] == 'python_test1' }['id']

    r = @client.put("agents/sources/#{id}", {
      name: 'python_test2',
      body: @data_builder.new_python_agent_body(3)
    })
    expect(r.status).to eq 200

    r = @client.get("agents/sources/#{id}")
    expect(r.status).to eq 200

    expect(r.body['id']).not_to be nil
    expect(r.body['error']).to be nil
    expect(r.body['status']).to eq 'normal'
    expect(r.body['name']).to eq 'python_test2'
    expect(r.body['body']).to eq @data_builder.new_python_agent_body(3)
  end

  it '`DELETE /agents/sources/:id` can delete an agent source' do
    r = @client.get('agents/sources')
    id = r.body.find { |a| a['name'] == 'python_test2' }['id']
    r = @client.delete("agents/sources/#{id}")
    expect(r.status).to eq 204

    r = @client.get("agents/sources/#{id}")
    expect(r.status).to eq 404
  end
end
