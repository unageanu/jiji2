# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/shared_contexts'

describe Jiji::Db::IndexBuilder do
  include_context 'use data_builder'

  it 'indexを作成できる' do
    Jiji::Db::IndexBuilder.new.create_indexes
  end
end
