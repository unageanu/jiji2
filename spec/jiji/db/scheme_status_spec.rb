# frozen_string_literal: true

require 'jiji/test/test_configuration'

describe Jiji::Db::SchemeStatus do
  include_context 'use data_builder'

  it 'scriptの適用状態を管理できる' do
    status = Jiji::Db::SchemeStatus.load

    expect(status.applied?('test')).to be false
    expect(status.applied?('test2')).to be false

    status.mark_as_applied('test')
    expect(status.applied?('test')).to be true
    expect(status.applied?('test2')).to be false

    status.save
    status = Jiji::Db::SchemeStatus.load
    expect(status.applied?('test')).to be true
    expect(status.applied?('test2')).to be false
  end
end
