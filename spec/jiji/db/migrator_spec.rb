# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Db::Migrator do
  include_context 'use container'
  include_context 'use data_builder'

  let(:migrator) { container.lookup(:migrator) }

  it 'データ移行ができる' do
    migrator1 = double('migrator1')
    allow(migrator1).to receive(:id).at_least(:once).and_return('01')
    expect(migrator1).to receive(:call).once

    migrator2 = double('migrator2')
    allow(migrator2).to receive(:id).at_least(:once).and_return('02')
    expect(migrator2).to receive(:call).once

    migrator3 = double('migrator3')
    allow(migrator3).to receive(:id).at_least(:once).and_return('03')
    expect(migrator3).to receive(:call).once

    migrator.register_script(migrator1)
    migrator.register_script(migrator2)
    migrator.register_script(migrator3)

    status = Jiji::Db::SchemeStatus.load
    expect(status.applied?('v0to1/register_system_agents')).to be false
    expect(status.applied?('01')).to be false
    expect(status.applied?('02')).to be false
    expect(status.applied?('03')).to be false

    migrator.migrate
    status = Jiji::Db::SchemeStatus.load
    expect(status.applied?('v0to1/register_system_agents')).to be true
    expect(status.applied?('01')).to be true
    expect(status.applied?('02')).to be true
    expect(status.applied?('03')).to be true

    migrator.migrate
    status = Jiji::Db::SchemeStatus.load
    expect(status.applied?('01')).to be true
    expect(status.applied?('02')).to be true
    expect(status.applied?('03')).to be true
  end

  it '途中でエラーになっても処理は継続される' do
    migrator1 = double('migrator1')
    allow(migrator1).to receive(:id).at_least(:once).and_return('01')
    expect(migrator1).to receive(:call).once

    migrator2 = double('migrator2')
    allow(migrator2).to receive(:id).at_least(:once).and_return('02')
    expect(migrator2).to receive(:call).and_raise('test').twice

    migrator3 = double('migrator3')
    allow(migrator3).to receive(:id).at_least(:once).and_return('03')
    expect(migrator3).to receive(:call).once

    migrator.register_script(migrator1)
    migrator.register_script(migrator2)
    migrator.register_script(migrator3)

    migrator.migrate
    status = Jiji::Db::SchemeStatus.load
    expect(status.applied?('01')).to be true
    expect(status.applied?('02')).to be false
    expect(status.applied?('03')).to be true

    migrator.migrate
  end
end
