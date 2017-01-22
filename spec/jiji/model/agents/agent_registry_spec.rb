# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Model::Agents::AgentRegistry do
  include_context 'use data_builder'
  include_context 'use container'

  before(:example) do
    @repository = container.lookup(:agent_source_repository)
    @registry = container.lookup(:agent_registry)
  end

  describe '登録' do
    it '登録できる' do
      @registry.add_source('aaa', '', :agent,
        new_body(1))

      expect(get_agent_class('TestAgent1@aaa')).not_to be nil
    end

    it '名前が重複するとエラー' do
      @registry.add_source('aaa', '', :agent, new_body(1))

      expect do
        @registry.add_source('aaa', '', :agent, new_body(2))
      end.to raise_exception(Jiji::Errors::AlreadyExistsException)
    end

    it 'コンパイルエラーのコードは登録されない' do
      @registry.add_source('aaa', '', :agent,
        new_body(1) + '; class Foo')

      expect(get_agent_class('TestAgent1@aaa')).to be nil
    end
  end

  describe '削除' do
    it '削除できる' do
      @registry.add_source('aaa', '', :agent, new_body(1))

      expect(get_agent_class('TestAgent1@aaa')).not_to be nil

      @registry.remove_source('aaa')
      expect(get_agent_class('TestAgent1@aaa')).to be nil

      new_container = Jiji::Test::TestContainerFactory.instance.new_container
      @repository   = new_container.lookup(:agent_source_repository)
      @registry = new_container.lookup(:agent_registry)

      expect(@registry.agent_sources.length).to be 0
      expect(get_agent_class('TestAgent1@aaa')).to be nil
    end

    it '削除対象がない場合エラー' do
      expect do
        @registry.remove_source('aaa')
      end.to raise_exception(Jiji::Errors::NotFoundException)
    end
  end

  describe 'リネーム' do
    it 'ファイル名を変更できる' do
      @registry.add_source('aaa', '', :agent, new_body(1))

      expect(get_agent_class('TestAgent1@aaa')).not_to be nil

      @registry.rename_source('aaa', 'aaa2')
      expect(get_agent_class('TestAgent1@aaa2')).not_to be nil
      expect(get_agent_class('TestAgent1@aaa')).to be nil
    end

    it '変更前と変更後が同じファイルの場合、何もしない' do
      @registry.add_source('aaa', '', :agent, new_body(1))
      @registry.rename_source('aaa', 'aaa')
      expect(get_agent_class('TestAgent1@aaa')).not_to be nil
    end

    it '変更対象がない場合エラー' do
      expect do
        @registry.rename_source('aaa', 'aaa2')
      end.to raise_exception(Jiji::Errors::NotFoundException)
    end

    it '同名のファイルが既に存在する場合、エラー' do
      @registry.add_source('aaa', '', :agent, new_body(1))
      @registry.add_source('bbb', '', :agent, new_body(1))
      expect do
        @registry.rename_source('aaa', 'bbb')
      end.to raise_exception(Jiji::Errors::AlreadyExistsException)
    end
  end

  describe '更新' do
    it '更新できる' do
      @registry.add_source('aaa', '', :agent, new_body(1))

      expect(get_agent_class('TestAgent1@aaa')).not_to be nil

      result = @registry.update_source('aaa', '', new_body(2))
      expect(result.name).to eq('aaa')

      expect(get_agent_class('TestAgent1@aaa')).to be nil
      expect(get_agent_class('TestAgent2@aaa')).not_to be nil
    end

    it '更新対象がない場合エラー' do
      expect do
        @registry.update_source('aaa', '',
          new_body(2))
      end.to raise_exception(Jiji::Errors::NotFoundException)
    end

    it 'コンパイルエラーのコードは登録されない' do
      @registry.add_source('aaa', '', :agent, new_body(1))

      expect(get_agent_class('TestAgent1@aaa')).not_to be nil

      @registry.update_source('aaa', '',
        new_body(2) + '; class Foo')

      expect(get_agent_class('TestAgent1@aaa')).to be nil
      expect(get_agent_class('TestAgent2@aaa')).to be nil
    end
  end

  it '名前一覧を取得できる' do
    names = @registry.map { |x| x[:name] }
    expect(names.length).to be 0

    @registry.add_source('aaa', '', :agent, new_body(1))
    @registry.add_source('bbb', '', :agent,
      new_body(2) + ';' + new_body(3))
    @registry.add_source('ccc', '', :agent, 'class Foo; end')
    @registry.add_source('ddd', '', :agent,
      'module Var;  class TestAgent; ' \
      + 'include Jiji::Model::Agents::Agent;  end; end')
    @registry.add_source('eee', '', :agent,
      'module Var;  module Var2; class TestAgent2;' \
      + 'include Jiji::Model::Agents::Agent;  end; end; end')
    @registry.add_source('fff', '', :agent, '')

    names = @registry.map { |x| x[:name] }
    expect(names.length).to be 5
    expect(names.include?('TestAgent1@aaa')).to be true
    expect(names.include?('TestAgent2@bbb')).to be true
    expect(names.include?('TestAgent3@bbb')).to be true
    expect(names.include?('Var::TestAgent@ddd')).to be true
    expect(names.include?('Var::Var2::TestAgent2@eee')).to be true
  end

  it 'ソース一覧を取得できる' do
    expect(@registry.agent_sources.length).to be 0

    @registry.add_source('aaa', '', :agent, new_body(1))
    @registry.add_source('bbb', '', :agent, new_body(2))
    @registry.add_source('ccc', '', :agent, new_body(3))

    expect(@registry.agent_sources.length).to be 3
  end

  describe '#find_agent_source_by_name' do
    it '名前でソースを取得できる' do
      @registry.add_source('aaa', '', :agent, new_body(1))
      @registry.add_source('bbb', '', :agent, new_body(2))
      @registry.add_source('ccc', '', :agent, new_body(3))

      expect(@registry.find_agent_source_by_name('aaa').name).to eq 'aaa'
    end
    it '名前に対応するソースが見つからない場合エラー' do
      expect do
        @registry.find_agent_source_by_name('aaa')
      end.to raise_exception(Jiji::Errors::NotFoundException)
    end
  end

  describe '#find_agent_source_by_id' do
    it 'idでソースを取得できる' do
      agent1 = @registry.add_source('aaa', '', :agent, new_body(1))
      @registry.add_source('bbb', '', :agent, new_body(2))
      @registry.add_source('ccc', '', :agent, new_body(3))

      expect(@registry.find_agent_source_by_id(agent1._id).name).to eq 'aaa'
    end
    it 'idに対応するソースが見つからない場合エラー' do
      expect do
        @registry.find_agent_source_by_id(BSON::ObjectId.new)
      end.to raise_exception(Jiji::Errors::NotFoundException)
    end
  end

  describe 'agent生成' do
    before(:example) do
      @registry.add_source('aaa', '', :agent, new_body(1))
      @registry.add_source('bbb', '', :agent,
        'module Var;  class TestAgent; ' \
        + 'include Jiji::Model::Agents::Agent;  end; end')
      @registry.add_source('ccc', '', :agent,
        'module Var;  class NotAgent; end; CONST="X"; module Mod; end; end')
    end

    it 'agentを作成できる' do
      agent = @registry.create_agent('TestAgent1@aaa', foo: 'var')
      expect(agent).not_to be nil
      expect(agent.properties[:foo]).to eq 'var'

      agent = @registry.create_agent('Var::TestAgent@bbb', foo: 'var2')
      expect(agent).not_to be nil
      expect(agent.properties[:foo]).to eq 'var2'
    end

    it '名前に対応するクラスが存在しない場合エラー' do
      expect do
        @registry.create_agent('TestAgentX@aaa')
      end.to raise_exception(Jiji::Errors::NotFoundException)
      expect do
        @registry.create_agent('TestAgent1@bbb')
      end.to raise_exception(Jiji::Errors::NotFoundException)
      expect do
        @registry.create_agent('Var::TestAgentX@bbb')
      end.to raise_exception(Jiji::Errors::NotFoundException)
    end

    it '定数やAgent派生でないクラスを指定した場合、エラー' do
      expect do
        @registry.create_agent('Var::NotAgent@ccc')
      end.to raise_exception(Jiji::Errors::NotFoundException)
      expect do
        @registry.create_agent('Var::CONST@ccc')
      end.to raise_exception(Jiji::Errors::NotFoundException)
      expect do
        @registry.create_agent('Var::Mod@ccc')
      end.to raise_exception(Jiji::Errors::NotFoundException)
    end
  end

  describe 'プロパティ/説明の取得' do
    before(:example) do
      @registry.add_source('aaa', '', :agent, new_body(1))
      @registry.add_source('bbb', '', :agent, new_body(2))
      @registry.add_source('ccc', '', :agent,
        'module Var;  class TestAgent; ' \
        + 'include Jiji::Model::Agents::Agent;  end; end')
    end

    it '説明取得' do
      hash = @registry.each_with_object({}) do |agent, h|
        h[agent[:name]] = agent[:description] if agent
      end
      expect(hash['TestAgent1@aaa']).to eq 'description1'
      expect(hash['TestAgent2@bbb']).to eq 'description2'
      expect(hash['Var::TestAgent@ccc']).to be nil
    end

    it 'プロパティ取得' do
      hash = @registry.each_with_object({}) do |agent, h|
        h[agent[:name]] = agent[:properties] if agent
      end
      expect(hash['TestAgent1@aaa']).to eq [
        Jiji::Model::Agents::Agent::Property.new(:a, 'aa', 1),
        Jiji::Model::Agents::Agent::Property.new(:b, 'bb', 1)
      ]
      expect(hash['TestAgent2@bbb']).to eq [
        Jiji::Model::Agents::Agent::Property.new(:a, 'aa', 1),
        Jiji::Model::Agents::Agent::Property.new(:b, 'bb', 2)
      ]
      expect(hash['Var::TestAgent@ccc']).to eq []
    end

    def get_deescription(name)
      @registry.get_agent_description(name)
    end
  end

  describe 'ソースをロードできる' do
    before(:example) do
      @registry.add_source('aaa', '', :agent, new_body(1))
      @registry.add_source('bbb', '', :agent, new_body(2))
      @registry.add_source('ccc', '', :agent, new_body(3, 'TestAgent1'))
      @registry.add_source('ddd', '', :agent, new_body(4, 'TestAgent2'))
      @registry.add_source('eee', '', :agent, new_body(5, 'TestAgent3'))

      # 1 <- 3 <- 5
      # 2 <- 4
    end

    it '依存関係に問題がない場合' do
      reload

      expect(@registry.agent_sources.length).to be 5
      @registry.agent_sources.each do |s|
        expect(s.status).to be :normal
      end

      names = @registry.map { |x| x[:name] }
      expect(names.length).to be 5
      expect(names.include?('TestAgent1@aaa')).to be true
      expect(names.include?('TestAgent2@bbb')).to be true
      expect(names.include?('TestAgent3@ccc')).to be true
      expect(names.include?('TestAgent4@ddd')).to be true
      expect(names.include?('TestAgent5@eee')).to be true
    end

    it '循環参照がある場合' do
      # 1 <- 3 <- 5
      #      ->6 ->5
      @registry.add_source('fff', '', :agent, new_body(6, 'TestAgent5'))
      @registry.update_source('ccc', '',
        new_body(3_2, 'TestAgent6') \
        + new_body(3, 'TestAgent1'))

      # 2 <-> 4
      @registry.update_source('bbb', '', new_body(2, 'TestAgent4'))

      @registry.agent_sources.each do |s|
        expect(s.status).to be :normal
      end

      reload

      expect(@registry.agent_sources.length).to be 6
      @registry.agent_sources.each do |s|
        if s.name == 'aaa'
          expect(s.status).to be :normal
        else
          expect(s.status).to be :error
        end
      end

      names = @registry.map { |x| x[:name] }
      expect(names.length).to be 1
      expect(names.include?('TestAgent1@aaa')).to be true
    end

    def reload
      new_container = Jiji::Test::TestContainerFactory.instance.new_container
      @repository   = new_container.lookup(:agent_source_repository)
      @registry = new_container.lookup(:agent_registry)
    end
  end

  it '他のソースで定義したクラス/モジュールを利用できる' do
    @registry.add_source('aaa', '', :agent, <<BODY
    module TestModule
      class TestClass
        def x
          "xxx"
        end
      end
    end
BODY
    )
    @registry.add_source('bbb', '', :agent, <<BODY
    module TestModule2
      class TestAgent2
        extend Jiji::Model::Agents::Context
        include Jiji::Model::Agents::Agent
        def post_create
          TestModule::TestClass.new
        end
      end
    end
    class TestAgent1
      extend Jiji::Model::Agents::Context
      include Jiji::Model::Agents::Agent
      def post_create
        TestModule::TestClass.new
      end
    end
BODY
    )
    names = @registry.map { |x| x[:name] }
    expect(names.length).to be 2
    expect(names.include?('TestModule2::TestAgent2@bbb')).to be true
    expect(names.include?('TestAgent1@bbb')).to be true

    agent = @registry.create_agent('TestModule2::TestAgent2@bbb')
    agent.post_create
    agent = @registry.create_agent('TestAgent1@bbb')
    agent.post_create

    new_container = Jiji::Test::TestContainerFactory.instance.new_container
    @repository   = new_container.lookup(:agent_source_repository)
    @registry = new_container.lookup(:agent_registry)

    agent = @registry.create_agent('TestModule2::TestAgent2@bbb')
    agent.post_create
    agent = @registry.create_agent('TestAgent1@bbb')
    agent.post_create
  end

  def new_body(seed, parent = nil)
    data_builder.new_agent_body(seed, parent)
  end

  def get_agent_class(name)
    @registry.find { |agent| agent[:name] == name }
  end
end
