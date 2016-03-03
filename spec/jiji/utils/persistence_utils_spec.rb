# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Utils::PersistenceUtils do
  describe '#get_or_create' do
    it 'エンティティがあれば取得/なければ作成ができる' do
      graph = Jiji::Model::Graphing::Graph
      results = []
      threads = Array.new(20) do |_i|
        Thread.new(results) do |r|
          10.times do |_n|
            r << Jiji::Utils::PersistenceUtils.get_or_create(
              proc { graph.find_by({ backtest: nil, label: 'test' }) },
              proc do
                graph.new(nil, :notmal, :last, 'test', [], [])
              end)
          end
        end
      end

      threads.each { |t| t.join }
      results.each do |r|
        expect(r).not_to be nil
      end
    end
  end
end
