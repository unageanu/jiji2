# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

describe Jiji::Model::Agents::AgentSource do
  before(:example) do
    @data_builder = Jiji::Test::DataBuilder.new

    @container    = Jiji::Test::TestContainerFactory.instance.new_container
    @repository   = @container.lookup(:agent_source_repository)
  end

  after(:example) do
    @data_builder.clean
  end

  context 'コードが空の場合' do
    it '新規作成できる' do
      agent_source = Jiji::Model::Agents::AgentSource.create(
        'test', :agent, Time.at(100))

      expect(agent_source._id).not_to be nil
      expect(agent_source.name).to eq 'test'
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(100)
      expect(agent_source.memo).to eq ''
      expect(agent_source.body).to eq ''
      expect(agent_source.error).to eq nil
      expect(agent_source.status).to eq :empty
    end

    it '有効なコードに変更できる' do
      agent_source = Jiji::Model::Agents::AgentSource.create(
        'test', :agent, Time.at(100))

      agent_source.update('test2', Time.at(200),
        'memo', "class Foo; def to_s; return \"xxx\"; end; end")

      expect(agent_source._id).not_to be nil
      expect(agent_source.name).to eq 'test2'
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq 'memo'
      expect(agent_source.body).to eq(
        "class Foo; def to_s; return \"xxx\"; end; end")
      expect(agent_source.status).to eq :normal
      expect(agent_source.error).to eq nil

      # 再読み込みしても同じ状態
      agent_source = @repository.get_by_id(agent_source._id)
      expect(agent_source.name).to eq 'test2'
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq 'memo'
      expect(agent_source.body).to eq(
        "class Foo; def to_s; return \"xxx\"; end; end")
      expect(agent_source.status).to eq :normal
      expect(agent_source.error).to eq nil
    end

    it '無効なコードに変更した場合、エラーになる' do
      agent_source = Jiji::Model::Agents::AgentSource.create(
        'test', :agent, Time.at(100))

      agent_source.update('test2', Time.at(200), 'memo', 'class Foo; ')

      expect(agent_source._id).not_to be nil
      expect(agent_source.name).to eq 'test2'
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq 'memo'
      expect(agent_source.body).to eq 'class Foo; '
      expect(agent_source.status).to eq :error
      expect(agent_source.error).not_to eq nil

      # 再読み込みしても同じ状態
      agent_source = @repository.get_by_id(agent_source._id)
      expect(agent_source.name).to eq 'test2'
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq 'memo'
      expect(agent_source.body).to eq 'class Foo; '
      expect(agent_source.status).to eq :error
      expect(agent_source.error).not_to eq nil
    end

    it '無効なコードを正しいコードで上書きできる' do
      agent_source = Jiji::Model::Agents::AgentSource.create(
        'test', :agent, Time.at(100))

      agent_source.update('test2', Time.at(200), 'memo', 'class Foo; ')

      expect(agent_source._id).not_to be nil
      expect(agent_source.name).to eq 'test2'
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq 'memo'
      expect(agent_source.body).to eq 'class Foo; '
      expect(agent_source.status).to eq :error
      expect(agent_source.error).not_to eq nil

      agent_source.update('test2', Time.at(200), 'memo',
        "class Foo; def to_s; return \"xxx\"; end; end")

      expect(agent_source._id).not_to be nil
      expect(agent_source.name).to eq 'test2'
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq 'memo'
      expect(agent_source.body).to eq(
        "class Foo; def to_s; return \"xxx\"; end; end")
      expect(agent_source.status).to eq :normal
      expect(agent_source.error).to eq nil

      # 再読み込みしても同じ状態
      agent_source = @repository.get_by_id(agent_source._id)
      expect(agent_source.name).to eq 'test2'
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq 'memo'
      expect(agent_source.body).to eq(
        "class Foo; def to_s; return \"xxx\"; end; end")
      expect(agent_source.status).to eq :normal
      expect(agent_source.error).to eq nil
    end
  end

  context 'コードが空ではない場合' do
    it '新規作成できる' do
      agent_source = Jiji::Model::Agents::AgentSource.create(
        'test', :agent, Time.at(100), 'memo',
        "class Var; def to_s; return \"var\"; end; end")

      expect(agent_source._id).not_to be nil
      expect(agent_source.name).to eq 'test'
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(100)
      expect(agent_source.memo).to eq 'memo'
      expect(agent_source.body).to eq(
        "class Var; def to_s; return \"var\"; end; end")
      expect(agent_source.status).to eq :normal
      expect(agent_source.error).to eq nil
    end

    it '有効なコードに変更できる' do
      agent_source = Jiji::Model::Agents::AgentSource.create(
        'test', :agent, Time.at(100), 'memo',
        "class Var; def to_s; return \"var\"; end; end")

      agent_source.update('test2', Time.at(200), 'memo',
        "class Foo; def to_s; return \"xxx\"; end; end")

      expect(agent_source._id).not_to be nil
      expect(agent_source.name).to eq 'test2'
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq 'memo'
      expect(agent_source.body).to eq(
        "class Foo; def to_s; return \"xxx\"; end; end")
      expect(agent_source.status).to eq :normal
      expect(agent_source.error).to eq nil

      # 再読み込みしても同じ状態
      agent_source = @repository.get_by_id(agent_source._id)
      expect(agent_source.name).to eq 'test2'
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq 'memo'
      expect(agent_source.body).to eq(
        "class Foo; def to_s; return \"xxx\"; end; end")
      expect(agent_source.status).to eq :normal
      expect(agent_source.error).to eq nil
    end

    it '無効なコードに変更した場合、エラーになる' do
      agent_source = Jiji::Model::Agents::AgentSource.create(
        'test', :agent, Time.at(100), 'memo',
        "class Var; def to_s; return \"var\"; end; end")

      agent_source.update('test2', Time.at(200), 'memo', 'class Foo; ')

      expect(agent_source._id).not_to be nil
      expect(agent_source.name).to eq 'test2'
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq 'memo'
      expect(agent_source.body).to eq 'class Foo; '
      expect(agent_source.status).to eq :error
      expect(agent_source.error).not_to eq nil

      # 再読み込みしても同じ状態
      agent_source = @repository.get_by_id(agent_source._id)
      expect(agent_source.name).to eq 'test2'
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq 'memo'
      expect(agent_source.body).to eq 'class Foo; '
      expect(agent_source.status).to eq :error
      expect(agent_source.error).not_to eq nil
    end
  end

  context 'コードがエラーになる場合' do
    it '新規作成できる' do
      agent_source = Jiji::Model::Agents::AgentSource.create(
        'test', :agent, Time.at(100), 'memo', 'class Var; ')

      expect(agent_source._id).not_to be nil
      expect(agent_source.name).to eq 'test'
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(100)
      expect(agent_source.memo).to eq 'memo'
      expect(agent_source.body).to eq 'class Var; '
      expect(agent_source.status).to eq :error
      expect(agent_source.error).not_to eq nil
    end

    it '有効なコードに変更できる' do
      agent_source = Jiji::Model::Agents::AgentSource.create(
        'test', :agent, Time.at(100), 'memo', 'class Var; ')

      agent_source.update('test2', Time.at(200), 'memo',
        "class Foo; def to_s; return \"xxx\"; end; end")

      expect(agent_source._id).not_to be nil
      expect(agent_source.name).to eq 'test2'
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq 'memo'
      expect(agent_source.body).to eq(
        "class Foo; def to_s; return \"xxx\"; end; end")
      expect(agent_source.status).to eq :normal
      expect(agent_source.error).to eq nil

      # 再読み込みしても同じ状態
      agent_source = @repository.get_by_id(agent_source._id)
      expect(agent_source.name).to eq 'test2'
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq 'memo'
      expect(agent_source.body).to eq(
        "class Foo; def to_s; return \"xxx\"; end; end")
      expect(agent_source.status).to eq :normal
      expect(agent_source.error).to eq nil
    end

    it '無効なコードに変更した場合、エラーになる' do
      agent_source = Jiji::Model::Agents::AgentSource.create(
        'test', :agent, Time.at(100), 'memo', 'class Var; ')

      agent_source.update('test2', Time.at(200), 'memo', 'class Foo; ')

      expect(agent_source._id).not_to be nil
      expect(agent_source.name).to eq 'test2'
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq 'memo'
      expect(agent_source.body).to eq 'class Foo; '
      expect(agent_source.status).to eq :error
      expect(agent_source.error).not_to eq nil

      # 再読み込みしても同じ状態
      agent_source = @repository.get_by_id(agent_source._id)
      expect(agent_source.name).to eq 'test2'
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq 'memo'
      expect(agent_source.body).to eq 'class Foo; '
      expect(agent_source.status).to eq :error
      expect(agent_source.error).not_to eq nil
    end
  end

  it '読み込んだコードを利用できる' do
    agent_source = Jiji::Model::Agents::AgentSource.create(
      'test', :agent, Time.at(100), 'memo',
      "class Foo; def to_s; return \"xxx\"; end; end")
    f = agent_source.context.const_get 'Foo'
    instance_f1 = f.new

    expect(instance_f1.to_s).to eq 'xxx'

    agent_source.update('test2', Time.at(200), 'memo',
      "class Foo; def to_s; return \"xxx2\"; end; end;" \
    + "class Var; def to_s; return \"var\";  end; end;")

    f2 = agent_source.context.const_get 'Foo'
    instance_f2 = f2.new
    v2 = agent_source.context.const_get 'Var'
    instance_v2 = v2.new

    expect(instance_f1.to_s).to eq 'xxx'
    expect(instance_f2.to_s).to eq 'xxx2'
    expect(instance_v2.to_s).to eq 'var'

    agent_source.update('test2', Time.at(200), 'memo', 'class Foo;')

    expect(instance_f1.to_s).to eq 'xxx'
    expect(instance_f2.to_s).to eq 'xxx2'
    expect(instance_v2.to_s).to eq 'var'
  end

  it '他のエージェントソースで定義されたクラスやモジュールを利用できる' do
    delegate = {}
    Jiji::Model::Agents::Context._delegates = delegate

    agent_source = Jiji::Model::Agents::AgentSource.create(
      'test', :agent, Time.at(100), 'memo',
      "class Foo; def method_1; return \"xxx\"; end; end;" \
      "def self.method_a; return \"aaa\"; end")
    delegate[agent_source.name] = agent_source.context

    agent_source2 = Jiji::Model::Agents::AgentSource.create(
      'test2', :agent, Time.at(100), nil,
      "class Foo2 < Foo; def method_2; return \"yyy\" + method_1; end; end;" \
      "def self.method_b; return method_a + \"bbb\"; end")
    delegate[agent_source2.name] = agent_source2.context

    f = agent_source2.context.const_get 'Foo2'
    instance = f.new

    expect(instance.method_1).to eq 'xxx'
    expect(instance.method_2).to eq 'yyyxxx'
    expect(agent_source2.context.method_a).to eq 'aaa'
    expect(agent_source2.context.method_b).to eq 'aaabbb'

    # 継承元を改変
    agent_source.update('test', Time.at(200), 'memo',
      "class Foo; def method_1; return \"xxx2\"; end; end;")
    delegate[agent_source.name] = agent_source.context

    # 生成済みインスタンスの動作は変わらない
    expect(instance.method_1).to eq 'xxx'
    expect(instance.method_2).to eq 'yyyxxx'
    expect { agent_source2.context.method_a }.to raise_exception(NameError)
    expect { agent_source2.context.method_b }.to raise_exception(NameError)

    # クラスを再定義するまで、派生クラスの動作は変わらない
    f = agent_source2.context.const_get 'Foo2'
    instance = f.new
    expect(instance.method_1).to eq 'xxx'
    expect(instance.method_2).to eq 'yyyxxx'
    expect { agent_source2.context.method_a }.to raise_exception(NameError)
    expect { agent_source2.context.method_b }.to raise_exception(NameError)

    # 派生クラスを再定義
    agent_source2.update('test2', Time.at(200), 'memo',
      "class Foo2 < Foo; def method_2; return \"zzz\" + method_1; end; end;" \
      "def self.method_b; return \"bbb\"; end")
    delegate[agent_source2.name] = agent_source2.context

    # 生成済みインスタンスの動作は変わらない
    expect(instance.method_1).to eq 'xxx'
    expect(instance.method_2).to eq 'yyyxxx'
    expect { agent_source2.context.method_a }.to raise_exception(NameError)
    expect(agent_source2.context.method_b).to eq 'bbb'

    # 派生クラスの動作が変わらる
    f = agent_source2.context.const_get 'Foo2'
    instance = f.new
    expect(instance.method_1).to eq 'xxx2'
    expect(instance.method_2).to eq 'zzzxxx2'
    expect { agent_source2.context.method_a }.to raise_exception(NameError)
    expect(agent_source2.context.method_b).to eq 'bbb'
  end

  it 'リークしない' do
    agent_source = Jiji::Model::Agents::AgentSource.create(
      'test', :agent, Time.at(100), 'memo',
      "class Foo; def to_s; return \"xxx\"; end; end")

    # 100000.times {|i|
    10.times do |_i|
      agent_source.update('test2', Time.at(200), 'memo',
        "class Foo; def to_s; return \"xxx2\"; end; end;" \
      + "class Var; def to_s; return \"var\";  end; end;")
      f = agent_source.context.const_get 'Foo'
      f.new
    end
  end

  it '名前が不正な場合エラーになる' do
    expect do
      Jiji::Model::Agents::AgentSource.create(
        nil, :agent, Time.at(100), 'memo', nil)
    end.to raise_exception(ActiveModel::StrictValidationFailed)

    expect do
      Jiji::Model::Agents::AgentSource.create(
        '', :agent, Time.at(100), 'memo', nil)
    end.to raise_exception(ActiveModel::StrictValidationFailed)

    expect do
      Jiji::Model::Agents::AgentSource.create(
        'a' * 201, :agent, Time.at(100), 'memo', nil)
    end.to raise_exception(ActiveModel::StrictValidationFailed)
  end

  it 'メモが不正な場合エラーになる' do
    expect do
      Jiji::Model::Agents::AgentSource.create(
        nil, :agent, Time.at(100), 'a' * 2001, nil)
    end.to raise_exception(ActiveModel::StrictValidationFailed)
  end

  it '作成時刻が不正な場合エラーになる' do
    expect do
      Jiji::Model::Agents::AgentSource.create(
        'a', :agent, nil, nil, nil)
    end.to raise_exception(ActiveModel::StrictValidationFailed)
  end

  it 'to_h で値をハッシュに変換できる' do
    agent_source = Jiji::Model::Agents::AgentSource.create(
      'test', :agent, Time.at(100), 'memo', 'class Foo; ')

    hash = agent_source.to_h
    p hash
    expect(hash[:id]).not_to be nil
    expect(hash[:name]).to eq 'test'
    expect(hash[:type]).to eq :agent
    expect(hash[:created_at]).to eq Time.at(100)
    expect(hash[:updated_at]).to eq Time.at(100)
    expect(hash[:memo]).to eq 'memo'
    expect(hash[:body]).to eq 'class Foo; '
    expect(hash[:error]).not_to be nil
    expect(hash[:status]).to eq :error
  end
end
