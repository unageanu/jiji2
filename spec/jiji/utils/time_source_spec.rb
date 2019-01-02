# frozen_string_literal: true

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Utils::TimeSource do
  it '日時を設定/取得できる' do
    time = Jiji::Utils::TimeSource.new

    expect(time.now).not_to be nil

    time.set(Time.new(2015, 1, 1))
    expect(time.now).to eq Time.new(2015, 1, 1)

    time.reset
    expect(time.now).not_to be nil

    time.set(Time.new(2015, 1, 2))
    expect(time.now).to eq Time.new(2015, 1, 2)
  end
end
