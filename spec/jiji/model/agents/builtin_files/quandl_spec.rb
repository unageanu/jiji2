# frozen_string_literal: true

require 'quandl'
require 'jiji/test/test_configuration'
require 'jiji/model/agents/builtin_files/cross'

describe 'Quandl' do
  it 'can retrieve latest data.' do
    data = Quandl::Dataset.get('TSE/9984').data(params: {
      limit: 1
    })
    expect(data.length).to be 1
    expect(data.first.open).to be > 0
    expect(data.first.close).to be > 0
    expect(data.first.high).to be > 0
    expect(data.first.low).to be > 0
    expect(data.first.date).to be > 0
  end

  it 'can retrieve data at 2016-02-05.' do
    data = Quandl::Dataset.get('TSE/9984').data(params: {
      limit:    1,
      end_date: '2016-02-05'
    })
    expect(data.length).to be 1
    expect(data.first.open).to be > 0
    expect(data.first.close).to be > 0
    expect(data.first.high).to be > 0
    expect(data.first.low).to be > 0
    expect(data.first.date).to eq Date.new(2016, 2, 5)
  end
end
