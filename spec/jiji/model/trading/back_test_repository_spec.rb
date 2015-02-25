# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Model::Trading::BackTestRepository do
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new

    @container    = Jiji::Test::TestContainerFactory.instance.new_container
    @repository   = @container.lookup(:back_test_repository)
    @time_source  = @container.lookup(:time_source)
  end

  after(:example) do
    @repository.stop
    @data_builder.clean
  end

  it 'テストを追加できる' do
    @data_builder.register_ticks(5, 60)

    expect(@repository.all.length).to be 0

    test = @repository.register('name'       => 'テスト',
                                'start_time' => Time.at(100),
                                'end_time'   => Time.at(200),
                                'memo'       => 'メモ')

    expect(test.name).to eq 'テスト'
    expect(test.memo).to eq 'メモ'
    expect(test.start_time).to eq Time.at(100)
    expect(test.end_time).to eq Time.at(200)

    expect(@repository.all.length).to be 1
    expect(@repository.all[0]).to be test

    test2 = @repository.register('name'       => 'テスト2',
                                 'start_time' => Time.at(100),
                                 'end_time'   => Time.at(300),
                                 'memo'       => 'メモ')

    expect(test2.name).to eq 'テスト2'
    expect(test2.memo).to eq 'メモ'
    expect(test2.start_time).to eq Time.at(100)
    expect(test2.end_time).to eq Time.at(300)

    expect(@repository.all.length).to be 2
    expect(@repository.all[0]).to be test
    expect(@repository.all[1]).to be test2
  end

  context 'テストが3つ登録されている場合' do
    before(:example) do
      @data_builder.register_ticks(5, 60)

      3.times do |i|
        @time_source.set(Time.at(i))

        @repository.register('name'       => "テスト#{i}",
                             'start_time' => Time.at(100),
                             'end_time'   => Time.at(200),
                             'memo'       => 'メモ')
      end
    end

    it '追加したテストは永続化され、再起動時に読み込まれる' do
      expect(@repository.all.length).to be 3

      @container    = Jiji::Test::TestContainerFactory.instance.new_container
      @repository   = @container.lookup(:back_test_repository)

      expect(@repository.all.length).to be 3
      expect(@repository.all[0].name).to eq 'テスト0'
      expect(@repository.all[1].name).to eq 'テスト1'
      expect(@repository.all[2].name).to eq 'テスト2'
    end

    it 'テストを削除できる' do
      expect(@repository.all.length).to be 3

      @repository.delete(@repository.all[1].id)

      expect(@repository.all.length).to be 2
      expect(@repository.all[0].name).to eq 'テスト0'
      expect(@repository.all[1].name).to eq 'テスト2'

      @container    = Jiji::Test::TestContainerFactory.instance.new_container
      @repository   = @container.lookup(:back_test_repository)

      expect(@repository.all.length).to be 2
      expect(@repository.all[0].name).to eq 'テスト0'
      expect(@repository.all[1].name).to eq 'テスト2'
    end

    it 'stopで全テストを停止できる' do
      @repository.stop
    end
  end
end
