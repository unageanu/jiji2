# frozen_string_literal: true

require 'jiji/test/test_configuration'

describe Jiji::Db::IndexBuilder do
  include_context 'use data_builder'

  it 'indexを作成できる' do
    Jiji::Db::IndexBuilder.new.create_indexes
  end
end
