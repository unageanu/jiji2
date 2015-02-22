# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Agents::AgentRegistry do
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new

    @container    = Jiji::Test::TestContainerFactory.instance.new_container
    @repository   = @container.lookup(:agent_source_repository)
    @registory    = @container.lookup(:agent_registry)
  end

  after(:example) do
    @data_builder.clean
  end

  describe '登録' do
    it '登録できる' do
      source1 = @registory.add_source('aaa', '', :agent,
                                      @data_builder.new_agent_body(1))

      expect(@registory.get_agent_class('TestAgent1@aaa')).not_to be nil
    end

    it '名前が重複するとエラー' do
      source1 = @registory.add_source('aaa', '', :agent,
                                      @data_builder.new_agent_body(1))

      expect do
        @registory.add_source('aaa', '', :agent,
                              @data_builder.new_agent_body(2))
      end.to raise_exception(Jiji::Errors::AlreadyExistsException)
    end

    it 'コンパイルエラーのコードは登録されない' do
      source1 = @registory.add_source('aaa', '', :agent,
                                      @data_builder.new_agent_body(1) + '; class Foo')
      expect { @registory.get_agent_class('TestAgent1@aaa') }.to raise_exception(Jiji::Errors::NotFoundException)
    end
  end

  describe '削除' do
    it '削除できる' do
      source1 = @registory.add_source('aaa', '', :agent,
                                      @data_builder.new_agent_body(1))

      expect(@registory.get_agent_class('TestAgent1@aaa')).not_to be nil

      @registory.remove_source('aaa')
      expect { @registory.get_agent_class('TestAgent1@aaa') }.to raise_exception(Jiji::Errors::NotFoundException)
    end

    it '削除対象がない場合エラー' do
      expect do
        @registory.remove_source('aaa')
      end.to raise_exception(Jiji::Errors::NotFoundException)
    end
  end

  describe '更新' do
    it '更新できる' do
      source1 = @registory.add_source('aaa', '', :agent,
                                      @data_builder.new_agent_body(1))

      expect(@registory.get_agent_class('TestAgent1@aaa')).not_to be nil

      @registory.update_source('aaa', '',
                               @data_builder.new_agent_body(2))

      expect { @registory.get_agent_class('TestAgent1@aaa') }.to raise_exception(Jiji::Errors::NotFoundException)
      expect(@registory.get_agent_class('TestAgent2@aaa')).not_to be nil
    end

    it '更新対象がない場合エラー' do
      expect do
        @registory.update_source('aaa', '',
                                 @data_builder.new_agent_body(2))
      end.to raise_exception(Jiji::Errors::NotFoundException)
    end

    it 'コンパイルエラーのコードは登録されない' do
      source1 = @registory.add_source('aaa', '', :agent,
                                      @data_builder.new_agent_body(1))

      expect(@registory.get_agent_class('TestAgent1@aaa')).not_to be nil

      @registory.update_source('aaa', '',
                               @data_builder.new_agent_body(2)  + '; class Foo')

      expect { @registory.get_agent_class('TestAgent1@aaa') }.to raise_exception(Jiji::Errors::NotFoundException)
      expect { @registory.get_agent_class('TestAgent2@aaa') }.to raise_exception(Jiji::Errors::NotFoundException)
    end
  end

  it '名前一覧を取得できる' do
    names = @registory.map { |x| x }
    expect(names.length).to be 0

    @registory.add_source('aaa', '', :agent, @data_builder.new_agent_body(1))
    @registory.add_source('bbb', '', :agent,
                          @data_builder.new_agent_body(2) + ';'  + @data_builder.new_agent_body(3))
    @registory.add_source('ccc', '', :agent, 'class Foo; end')
    @registory.add_source('ddd', '', :agent, 'module Var;  class TestAgent; include Jiji::Model::Agents::Agent;  end; end')
    @registory.add_source('eee', '', :agent, 'module Var;  module Var2; class TestAgent2; include Jiji::Model::Agents::Agent;  end; end; end')

    names = @registory.map { |x| x }
    expect(names.length).to be 5
    expect(names.include?('TestAgent1@aaa')).to be true
    expect(names.include?('TestAgent2@bbb')).to be true
    expect(names.include?('TestAgent3@bbb')).to be true
    expect(names.include?('Var::TestAgent@ddd')).to be true
    expect(names.include?('Var::Var2::TestAgent2@eee')).to be true
  end

  it 'ソース一覧を取得できる' do
    expect(@registory.agent_sources.length).to be 0

    @registory.add_source('aaa', '', :agent, @data_builder.new_agent_body(1))
    @registory.add_source('bbb', '', :agent, @data_builder.new_agent_body(2))
    @registory.add_source('ccc', '', :agent, @data_builder.new_agent_body(3))

    expect(@registory.agent_sources.length).to be 3
  end

  describe 'agent生成' do
    before(:example) do
      @registory.add_source('aaa', '', :agent, @data_builder.new_agent_body(1))
      @registory.add_source('bbb', '', :agent, 'module Var;  class TestAgent; include Jiji::Model::Agents::Agent;  end; end')
      @registory.add_source('ccc', '', :agent, "module Var;  class NotAgent; end; CONST='X'; module Mod; end; end")
    end

    it 'agentを作成できる' do
      agent = @registory.create_agent('TestAgent1@aaa', foo: 'var')
      expect(agent).not_to be nil
      expect(agent.properties[:foo]).to eq 'var'

      agent = @registory.create_agent('Var::TestAgent@bbb', foo: 'var2')
      expect(agent).not_to be nil
      expect(agent.properties[:foo]).to eq 'var2'
    end

    it '名前に対応するクラスが存在しない場合エラー' do
      expect { @registory.create_agent('TestAgentX@aaa') }.to raise_exception(Jiji::Errors::NotFoundException)
      expect { @registory.create_agent('TestAgent1@bbb') }.to raise_exception(Jiji::Errors::NotFoundException)
      expect { @registory.create_agent('Var::TestAgentX@bbb') }.to raise_exception(Jiji::Errors::NotFoundException)
    end

    it '定数やAgent派生でないクラスを指定した場合、エラー' do
      expect { @registory.create_agent('Var::NotAgent@ccc') }.to raise_exception(Jiji::Errors::NotFoundException)
      expect { @registory.create_agent('Var::CONST@ccc') }.to raise_exception(Jiji::Errors::NotFoundException)
      expect { @registory.create_agent('Var::Mod@ccc') }.to raise_exception(Jiji::Errors::NotFoundException)
    end
  end

  describe 'プロパティ/説明の取得' do
    before(:example) do
      @registory.add_source('aaa', '', :agent, @data_builder.new_agent_body(1))
      @registory.add_source('bbb', '', :agent, @data_builder.new_agent_body(2))
      @registory.add_source('ccc', '', :agent, 'module Var;  class TestAgent; include Jiji::Model::Agents::Agent;  end; end')
    end

    it '説明取得' do
      expect(@registory.get_agent_description('TestAgent1@aaa')).to eq 'description1'
      expect(@registory.get_agent_description('TestAgent2@bbb')).to eq 'description2'
      expect(@registory.get_agent_description('Var::TestAgent@ccc')).to be nil
    end

    it 'プロパティ取得' do
      expect(@registory.get_agent_property_infos('TestAgent1@aaa')).to eq [
        Jiji::Model::Agents::Agent::Property.new(:a, 'aa', 1),
        Jiji::Model::Agents::Agent::Property.new(:b, 'bb', 1)
      ]
      expect(@registory.get_agent_property_infos('TestAgent2@bbb')).to eq [
        Jiji::Model::Agents::Agent::Property.new(:a, 'aa', 1),
        Jiji::Model::Agents::Agent::Property.new(:b, 'bb', 2)
      ]
      expect(@registory.get_agent_property_infos('Var::TestAgent@ccc')).to eq []
    end
  end

  describe 'ソースをロードできる' do
    before(:example) do
      @registory.add_source('aaa', '', :agent, @data_builder.new_agent_body(1))
      @registory.add_source('bbb', '', :agent, @data_builder.new_agent_body(2))
      @registory.add_source('ccc', '', :agent, @data_builder.new_agent_body(3, 'TestAgent1'))
      @registory.add_source('ddd', '', :agent, @data_builder.new_agent_body(4, 'TestAgent2'))
      @registory.add_source('eee', '', :agent, @data_builder.new_agent_body(5, 'TestAgent3'))

      # 1 <- 3 <- 5
      # 2 <- 4
    end

    it '依存関係に問題がない場合' do
      reload

      expect(@registory.agent_sources.length).to be 5
      @registory.agent_sources.each do|s|
        expect(s.status).to be :normal
      end

      names = @registory.map { |x| x }
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
      @registory.add_source('fff', '', :agent, @data_builder.new_agent_body(6, 'TestAgent5'))
      @registory.update_source('ccc', '',
                               @data_builder.new_agent_body(3_2, 'TestAgent6') \
                             + @data_builder.new_agent_body(3, 'TestAgent1'))

      # 2 <-> 4
      @registory.update_source('bbb', '', @data_builder.new_agent_body(2, 'TestAgent4'))

      @registory.agent_sources.each do|s|
        expect(s.status).to be :normal
      end

      reload

      expect(@registory.agent_sources.length).to be 6
      @registory.agent_sources.each do|s|
        if (s.name == 'aaa')
          expect(s.status).to be :normal
        else
          expect(s.status).to be :error
        end
      end

      names = @registory.map { |x| x }
      expect(names.length).to be 1
      expect(names.include?('TestAgent1@aaa')).to be true
    end

    def reload
      @container    = Jiji::Test::TestContainerFactory.instance.new_container
      @repository   = @container.lookup(:agent_source_repository)
      @registory    = @container.lookup(:agent_registry)
    end
  end
end
