# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Trading::Internal::RMTNextTickJobGenerator do
  before(:example) do
    @generator =
      Jiji::Model::Trading::Internal::RMTNextTickJobGenerator.new(0.2)
  end

  it 'wait_timeごとにjobが追加される' do
    queue = [] # 本当はThread.Queueを使うが、テスト時はモックを使う

    @generator.start(queue)
    sleep 0.1
    expect(queue.length).to eq 1

    sleep 0.2
    expect(queue.length).to eq 2

    sleep 1
    expect(queue.length).to eq 7

    @generator.stop

    sleep 0.5
    expect(queue.length).to eq 7
  end
end
