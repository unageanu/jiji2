# frozen_string_literal: true

describe 'アイコン' do
  let(:data_builder) { Jiji::Test::DataBuilder.new }

  before(:example) do
    @client = Jiji::Client.instance
  end

  it 'POST /icons でアイコンを登録できる' do
    r = @client.post_file('icons',
      data_builder.base_dir + '/sample_images/01.gif')
    expect(r.status).to eq 200

    r = @client.get("icons/#{r.body['id']}")
    expect(r.status).to eq 200
    expect(r.body['id']).not_to be nil
    expect(r.body['created_at']).not_to be nil
  end

  it 'GET /icons/:id/image でアイコンデータを取得できる' do
    r = @client.get('icons')
    id = r.body[0]['id']

    r = @client.get("icon-images/#{id}")
    expect(r.status).to eq 200
  end

  it '存在しないidを指定するとデフォルトアイコンが返される' do
    r = @client.get('icon-images/unknown')
    expect(r.status).to eq 200
  end

  it 'GET /icons でアイコン一覧を取得できる' do
    r = @client.get('icons')
    expect(r.status).to eq 200
    expect(r.body.length).to eq 5
    expect(r.body[0]['id']).not_to be nil
    expect(r.body[0]['created_at']).not_to be nil
  end

  it 'DELETE /icons/:id でアイコンデータを削除できる' do
    r = @client.get('icons')
    id = r.body[0]['id']

    r = @client.delete("icons/#{id}")
    expect(r.status).to eq 200

    r = @client.get('icons')
    expect(r.status).to eq 200
    expect(r.body.length).to eq 4
  end
end
