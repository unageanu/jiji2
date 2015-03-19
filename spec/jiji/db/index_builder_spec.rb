# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Db::IndexBuilder do
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new
  end

  after(:example) do
    @data_builder.clean
  end

  it 'indexを作成できる' do
    Jiji::Db::IndexBuilder.new.create_indexes
  end
end
