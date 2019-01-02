# frozen_string_literal: true

require 'jiji/test/test_configuration'

describe Jiji::Model::Icons::IconRepository do
  include_context 'use container'
  include_context 'use data_builder'

  let(:repository) { container.lookup(:icon_repository) }

  it 'アイコンを登録/取得/削除できる' do
    icon = repository.add(data_builder.read_image_date('01.png'))
    icon = repository.get(icon.id)

    expect(icon.created_at).not_to be nil
    expect(icon.image).not_to be nil
    expect(icon.to_h).to eq({ id: icon.id, created_at: icon.created_at })

    repository.delete(icon.id)
    expect do
      repository.get(icon.id)
    end.to raise_exception(Jiji::Errors::NotFoundException)
  end

  it 'allですべてのアイコンを取得できる' do
    ['01.gif', '01.jpg', '02.jpg'].each do |name|
      repository.add(data_builder.read_image_date(name))
    end

    icons = repository.all
    expect(icons.length).to be 3
    icons.each do |icon|
      expect(icon.created_at).not_to be nil
      expect(icon.to_h).to eq({ id: icon.id, created_at: icon.created_at })
    end
  end
end
