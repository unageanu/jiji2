# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Model::Agents::AgentSource do
  include_context 'use data_builder'
  include_context 'use container'
  let(:repository) { container.lookup(:agent_source_repository) }
  let(:ruby_agent_service) { container.lookup(:ruby_agent_service) }

  context 'コードが空の場合' do
    it '新規作成できる' do
      agent_source = Jiji::Model::Agents::AgentSource.create(
        'test', :agent, Time.at(100))
      ruby_agent_service.evaluate(agent_source)

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
      ruby_agent_service.evaluate(agent_source)

      agent_source.update('test2', Time.at(200),
        'memo', 'class Foo; def to_s; return "xxx"; end; end')
      ruby_agent_service.evaluate(agent_source)
      agent_source.save

      expect(agent_source._id).not_to be nil
      expect(agent_source.name).to eq 'test2'
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq 'memo'
      expect(agent_source.body).to eq(
        'class Foo; def to_s; return "xxx"; end; end')
      expect(agent_source.status).to eq :normal
      expect(agent_source.error).to eq nil

      # 再読み込みしても同じ状態
      agent_source = repository.get_by_id(agent_source._id)
      expect(agent_source.name).to eq 'test2'
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq 'memo'
      expect(agent_source.body).to eq(
        'class Foo; def to_s; return "xxx"; end; end')
      expect(agent_source.status).to eq :normal
      expect(agent_source.error).to eq nil
    end

    it '無効なコードに変更した場合、エラーになる' do
      agent_source = Jiji::Model::Agents::AgentSource.create(
        'test', :agent, Time.at(100))
      ruby_agent_service.evaluate(agent_source)

      agent_source.update('test2', Time.at(200), 'memo', 'class Foo; ')
      ruby_agent_service.evaluate(agent_source)
      agent_source.save

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
      agent_source = repository.get_by_id(agent_source._id)
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
      ruby_agent_service.evaluate(agent_source)

      agent_source.update('test2', Time.at(200), 'memo', 'class Foo; ')
      ruby_agent_service.evaluate(agent_source)

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
        'class Foo; def to_s; return "xxx"; end; end')
      ruby_agent_service.evaluate(agent_source)
      agent_source.save

      expect(agent_source._id).not_to be nil
      expect(agent_source.name).to eq 'test2'
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq 'memo'
      expect(agent_source.body).to eq(
        'class Foo; def to_s; return "xxx"; end; end')
      expect(agent_source.status).to eq :normal
      expect(agent_source.error).to eq nil

      # 再読み込みしても同じ状態
      agent_source = repository.get_by_id(agent_source._id)
      expect(agent_source.name).to eq 'test2'
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq 'memo'
      expect(agent_source.body).to eq(
        'class Foo; def to_s; return "xxx"; end; end')
      expect(agent_source.status).to eq :normal
      expect(agent_source.error).to eq nil
    end
  end

  context 'コードが空ではない場合' do
    it '新規作成できる' do
      agent_source = Jiji::Model::Agents::AgentSource.create(
        'test', :agent, Time.at(100), 'memo',
        'class Var; def to_s; return "var"; end; end')
      ruby_agent_service.evaluate(agent_source)

      expect(agent_source._id).not_to be nil
      expect(agent_source.name).to eq 'test'
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(100)
      expect(agent_source.memo).to eq 'memo'
      expect(agent_source.body).to eq(
        'class Var; def to_s; return "var"; end; end')
      expect(agent_source.status).to eq :normal
      expect(agent_source.error).to eq nil
    end

    it '有効なコードに変更できる' do
      agent_source = Jiji::Model::Agents::AgentSource.create(
        'test', :agent, Time.at(100), 'memo',
        'class Var; def to_s; return "var"; end; end')
      ruby_agent_service.evaluate(agent_source)

      agent_source.update('test2', Time.at(200), 'memo',
        'class Foo; def to_s; return "xxx"; end; end')
      ruby_agent_service.evaluate(agent_source)
      agent_source.save

      expect(agent_source._id).not_to be nil
      expect(agent_source.name).to eq 'test2'
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq 'memo'
      expect(agent_source.body).to eq(
        'class Foo; def to_s; return "xxx"; end; end')
      expect(agent_source.status).to eq :normal
      expect(agent_source.error).to eq nil

      # 再読み込みしても同じ状態
      agent_source = repository.get_by_id(agent_source._id)
      expect(agent_source.name).to eq 'test2'
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq 'memo'
      expect(agent_source.body).to eq(
        'class Foo; def to_s; return "xxx"; end; end')
      expect(agent_source.status).to eq :normal
      expect(agent_source.error).to eq nil
    end

    it '無効なコードに変更した場合、エラーになる' do
      agent_source = Jiji::Model::Agents::AgentSource.create(
        'test', :agent, Time.at(100), 'memo',
        'class Var; def to_s; return "var"; end; end')
      ruby_agent_service.evaluate(agent_source)

      agent_source.update('test2', Time.at(200), 'memo', 'class Foo; ')
      ruby_agent_service.evaluate(agent_source)
      agent_source.save

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
      agent_source = repository.get_by_id(agent_source._id)
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
      ruby_agent_service.evaluate(agent_source)

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
      ruby_agent_service.evaluate(agent_source)

      agent_source.update('test2', Time.at(200), 'memo',
        'class Foo; def to_s; return "xxx"; end; end')
      ruby_agent_service.evaluate(agent_source)
      agent_source.save

      expect(agent_source._id).not_to be nil
      expect(agent_source.name).to eq 'test2'
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq 'memo'
      expect(agent_source.body).to eq(
        'class Foo; def to_s; return "xxx"; end; end')
      expect(agent_source.status).to eq :normal
      expect(agent_source.error).to eq nil

      # 再読み込みしても同じ状態
      agent_source = repository.get_by_id(agent_source._id)
      expect(agent_source.name).to eq 'test2'
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq 'memo'
      expect(agent_source.body).to eq(
        'class Foo; def to_s; return "xxx"; end; end')
      expect(agent_source.status).to eq :normal
      expect(agent_source.error).to eq nil
    end

    it '無効なコードに変更した場合、エラーになる' do
      agent_source = Jiji::Model::Agents::AgentSource.create(
        'test', :agent, Time.at(100), 'memo', 'class Var; ')
      ruby_agent_service.evaluate(agent_source)

      agent_source.update('test2', Time.at(200), 'memo', 'class Foo; ')
      ruby_agent_service.evaluate(agent_source)
      agent_source.save

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
      agent_source = repository.get_by_id(agent_source._id)
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
      'class Foo; def to_s; return "xxx"; end; end')
    context = ruby_agent_service.evaluate(agent_source)

    f = context.const_get 'Foo'
    instance_f1 = f.new

    expect(instance_f1.to_s).to eq 'xxx'

    agent_source.update('test2', Time.at(200), 'memo',
      'class Foo; def to_s; return "xxx2"; end; end;' \
    + 'class Var; def to_s; return "var";  end; end;')
    context = ruby_agent_service.evaluate(agent_source)

    f2 = context.const_get 'Foo'
    instance_f2 = f2.new
    v2 = context.const_get 'Var'
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

    agent_source = Jiji::Model::Agents::AgentSource.create(
      'test', :agent, Time.at(100), 'memo', <<BODY
      class Foo
        def method_1
          return "xxx"
        end
      end
      def self.method_a
        return "aaa"
      end
      module TestModule
        class TestClass
          def method_y
            'yyy'
          end
        end
      end
BODY
    )
    context = ruby_agent_service.evaluate(agent_source)
    delegate[agent_source.name] = context

    Jiji::Model::Agents::Context._delegates = delegate

    agent_source2 = Jiji::Model::Agents::AgentSource.create(
      'test2', :agent, Time.at(100), nil, <<BODY
      class Foo2 < Foo
        extend Jiji::Model::Agents::Context
        include TestModule

        def method_2
          return "yyy" + method_1
        end
        def method_3
          return TestModule::TestClass.new.method_y + "bbb"
        end
      end
      def self.method_b
        return method_a + "bbb"
      end
BODY
    )
    context = ruby_agent_service.evaluate(agent_source2)
    delegate[agent_source2.name] = context

    f = context.const_get 'Foo2'
    instance = f.new

    expect(instance.method_1).to eq 'xxx'
    expect(instance.method_2).to eq 'yyyxxx'
    expect(instance.method_3).to eq 'yyybbb'
    expect(delegate[agent_source2.name].respond_to?(:method_a)).to be true
    expect(delegate[agent_source2.name].respond_to?(:method_b)).to be true
    expect(delegate[agent_source2.name].respond_to?(:method_x)).to be false
    expect(delegate[agent_source2.name].method_a).to eq 'aaa'
    expect(delegate[agent_source2.name].method_b).to eq 'aaabbb'

    # 継承元を改変
    agent_source.update('test', Time.at(200), 'memo',
      'class Foo; def method_1; return "xxx2"; end; end;')
    context = ruby_agent_service.evaluate(agent_source)
    delegate[agent_source.name] = context
    context2 = delegate[agent_source2.name]

    # 生成済みインスタンスの動作は変わらない
    expect(instance.method_1).to eq 'xxx'
    expect(instance.method_2).to eq 'yyyxxx'
    expect { context2.method_a }.to raise_exception(NameError)
    expect { context2.method_b }.to raise_exception(NameError)

    # クラスを再定義するまで、派生クラスの動作は変わらない
    f = delegate[agent_source2.name].const_get 'Foo2'
    instance = f.new
    expect(instance.method_1).to eq 'xxx'
    expect(instance.method_2).to eq 'yyyxxx'
    expect { context2.method_a }.to raise_exception(NameError)
    expect { context2.method_b }.to raise_exception(NameError)

    # 派生クラスを再定義
    agent_source2.update('test2', Time.at(200), 'memo',
      'class Foo2 < Foo; def method_2; return "zzz" + method_1; end; end;' \
      'def self.method_b; return "bbb"; end')
    context = ruby_agent_service.evaluate(agent_source2)
    delegate[agent_source2.name] = context

    # 生成済みインスタンスの動作は変わらない
    expect(instance.method_1).to eq 'xxx'
    expect(instance.method_2).to eq 'yyyxxx'
    expect { context.method_a }.to raise_exception(NameError)
    expect(delegate[agent_source2.name].method_b).to eq 'bbb'

    # 派生クラスの動作が変わらる
    f = delegate[agent_source2.name].const_get 'Foo2'
    instance = f.new
    expect(instance.method_1).to eq 'xxx2'
    expect(instance.method_2).to eq 'zzzxxx2'
    expect { context.method_a }.to raise_exception(NameError)
    expect(delegate[agent_source2.name].method_b).to eq 'bbb'
  end

  it 'リークしない' do
    agent_source = Jiji::Model::Agents::AgentSource.create(
      'test', :agent, Time.at(100), 'memo',
      'class Foo; def to_s; return "xxx"; end; end')
    context = ruby_agent_service.evaluate(agent_source)

    # 100000.times {|i|
    10.times do |_i|
      agent_source.update('test2', Time.at(200), 'memo',
        'class Foo; def to_s; return "xxx2"; end; end;' \
      + 'class Var; def to_s; return "var";  end; end;')
      context = ruby_agent_service.evaluate(agent_source)
      f = context.const_get 'Foo'
      f.new
    end
  end

  it '名前が不正な場合エラーになる' do
    expect do
      agent_source = Jiji::Model::Agents::AgentSource.create(
        nil, :agent, Time.at(100), 'memo', nil)
      agent_source.save
    end.to raise_exception(ActiveModel::StrictValidationFailed)

    expect do
      agent_source = Jiji::Model::Agents::AgentSource.create(
        '', :agent, Time.at(100), 'memo', nil)
      agent_source.save
    end.to raise_exception(ActiveModel::StrictValidationFailed)

    expect do
      agent_source = Jiji::Model::Agents::AgentSource.create(
        'a' * 201, :agent, Time.at(100), 'memo', nil)
      agent_source.save
    end.to raise_exception(ActiveModel::StrictValidationFailed)
  end

  it 'メモが不正な場合エラーになる' do
    expect do
      agent_source = Jiji::Model::Agents::AgentSource.create(
        nil, :agent, Time.at(100), 'a' * 2001, nil)
      agent_source.save
    end.to raise_exception(ActiveModel::StrictValidationFailed)
  end

  it '作成時刻が不正な場合エラーになる' do
    expect do
      agent_source = Jiji::Model::Agents::AgentSource.create(
        'a', :agent, nil, nil, nil)
      agent_source.save
    end.to raise_exception(ActiveModel::StrictValidationFailed)
  end

  it 'to_h で値をハッシュに変換できる' do
    agent_source = Jiji::Model::Agents::AgentSource.create(
      'test', :agent, Time.at(100), 'memo', 'class Foo; ')
    ruby_agent_service.evaluate(agent_source)

    hash = agent_source.to_h
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
