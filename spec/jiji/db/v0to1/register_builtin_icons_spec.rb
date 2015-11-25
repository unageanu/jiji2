# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Db::RegisterBuiltinIcons do
  include_context 'use container'

  let(:script) { container.lookup(:v0to1_register_builtin_icons) }
  let(:icon_repository) { container.lookup(:icon_repository) }

  it '#id' do
    expect(script.id).to eq 'v0to1/register_builtin_icons'
  end

  it '#call' do
    expect(icon_repository.all.length).to eq 0
    script.call(nil, nil)
    expect(icon_repository.all.length).to eq 4
  end
end
