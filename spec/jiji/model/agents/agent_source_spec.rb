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
  
  context "コードが空の場合" do
    it "新規作成できる" do
      agent_source = Jiji::Model::Agents::AgentSource.create(
            "test", :agent, Time.at(100))
      
      expect(agent_source._id).not_to be nil
      expect(agent_source.name).to eq "test"
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(100)
      expect(agent_source.memo).to eq ""
      expect(agent_source.body).to eq ""
      expect(agent_source.status).to eq :empty
      expect(agent_source.error).to eq nil
    end
    
    it "有効なコードに変更できる" do
      agent_source = Jiji::Model::Agents::AgentSource.create(
            "test", :agent, Time.at(100))
      
      agent_source.update("test2", Time.at(200), "memo", "class Foo; def to_s; return \"xxx\"; end; end")
      
      expect(agent_source._id).not_to be nil
      expect(agent_source.name).to eq "test2"
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq "memo"
      expect(agent_source.body).to eq "class Foo; def to_s; return \"xxx\"; end; end"
      expect(agent_source.status).to eq :normal
      expect(agent_source.error).to eq nil
      
      # 再読み込みしても同じ状態
      agent_source = @repository.get_by_id_with_body( agent_source._id )
      expect(agent_source.name).to eq "test2"
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq "memo"
      expect(agent_source.body).to eq "class Foo; def to_s; return \"xxx\"; end; end"
      expect(agent_source.status).to eq :normal
      expect(agent_source.error).to eq nil
    end
    
    it "無効なコードに変更した場合、エラーになる" do
      agent_source = Jiji::Model::Agents::AgentSource.create(
            "test", :agent, Time.at(100))
      
      agent_source.update("test2", Time.at(200), "memo", "class Foo; ")
      
      expect(agent_source._id).not_to be nil
      expect(agent_source.name).to eq "test2"
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq "memo"
      expect(agent_source.body).to eq "class Foo; "
      expect(agent_source.status).to eq :error
      expect(agent_source.error).not_to eq nil
      
      # 再読み込みしても同じ状態
      agent_source = @repository.get_by_id_with_body( agent_source._id )
      expect(agent_source.name).to eq "test2"
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq "memo"
      expect(agent_source.body).to eq "class Foo; "
      expect(agent_source.status).to eq :error
      expect(agent_source.error).not_to eq nil
      
    end
    
    it "無効なコードを正しいコードで上書きできる" do
      agent_source = Jiji::Model::Agents::AgentSource.create(
            "test", :agent, Time.at(100))
      
      agent_source.update("test2", Time.at(200), "memo", "class Foo; ")
      
      expect(agent_source._id).not_to be nil
      expect(agent_source.name).to eq "test2"
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq "memo"
      expect(agent_source.body).to eq "class Foo; "
      expect(agent_source.status).to eq :error
      expect(agent_source.error).not_to eq nil
      
      agent_source.update("test2", Time.at(200), "memo", "class Foo; def to_s; return \"xxx\"; end; end")
      
      expect(agent_source._id).not_to be nil
      expect(agent_source.name).to eq "test2"
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq "memo"
      expect(agent_source.body).to eq "class Foo; def to_s; return \"xxx\"; end; end"
      expect(agent_source.status).to eq :normal
      expect(agent_source.error).to eq nil
      
      # 再読み込みしても同じ状態
      agent_source = @repository.get_by_id_with_body( agent_source._id )
      expect(agent_source.name).to eq "test2"
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq "memo"
      expect(agent_source.body).to eq "class Foo; def to_s; return \"xxx\"; end; end"
      expect(agent_source.status).to eq :normal
      expect(agent_source.error).to eq nil
    end
  end
  
  context "コードが空ではない場合" do
    it "新規作成できる" do
      agent_source = Jiji::Model::Agents::AgentSource.create(
            "test", :agent, Time.at(100), "memo", "class Var; def to_s; return \"var\"; end; end")
      
      expect(agent_source._id).not_to be nil
      expect(agent_source.name).to eq "test"
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(100)
      expect(agent_source.memo).to eq "memo"
      expect(agent_source.body).to eq "class Var; def to_s; return \"var\"; end; end"
      expect(agent_source.status).to eq :normal
      expect(agent_source.error).to eq nil
    end
    
    it "有効なコードに変更できる" do
      agent_source = Jiji::Model::Agents::AgentSource.create(
            "test", :agent, Time.at(100), "memo", "class Var; def to_s; return \"var\"; end; end")
      
      agent_source.update("test2", Time.at(200), "memo", "class Foo; def to_s; return \"xxx\"; end; end")
      
      expect(agent_source._id).not_to be nil
      expect(agent_source.name).to eq "test2"
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq "memo"
      expect(agent_source.body).to eq "class Foo; def to_s; return \"xxx\"; end; end"
      expect(agent_source.status).to eq :normal
      expect(agent_source.error).to eq nil
      
      # 再読み込みしても同じ状態
      agent_source = @repository.get_by_id_with_body( agent_source._id )
      expect(agent_source.name).to eq "test2"
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq "memo"
      expect(agent_source.body).to eq "class Foo; def to_s; return \"xxx\"; end; end"
      expect(agent_source.status).to eq :normal
      expect(agent_source.error).to eq nil
    end
    
    it "無効なコードに変更した場合、エラーになる" do
      agent_source = Jiji::Model::Agents::AgentSource.create(
            "test", :agent, Time.at(100), "memo", "class Var; def to_s; return \"var\"; end; end")
      
      agent_source.update("test2", Time.at(200), "memo", "class Foo; ")
      
      expect(agent_source._id).not_to be nil
      expect(agent_source.name).to eq "test2"
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq "memo"
      expect(agent_source.body).to eq "class Foo; "
      expect(agent_source.status).to eq :error
      expect(agent_source.error).not_to eq nil
      
      # 再読み込みしても同じ状態
      agent_source = @repository.get_by_id_with_body( agent_source._id )
      expect(agent_source.name).to eq "test2"
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq "memo"
      expect(agent_source.body).to eq "class Foo; "
      expect(agent_source.status).to eq :error
      expect(agent_source.error).not_to eq nil
    end
  end
  
  context "コードがエラーになる場合" do
    it "新規作成できる" do
      agent_source = Jiji::Model::Agents::AgentSource.create(
            "test", :agent, Time.at(100), "memo", "class Var; ")
      
      expect(agent_source._id).not_to be nil
      expect(agent_source.name).to eq "test"
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(100)
      expect(agent_source.memo).to eq "memo"
      expect(agent_source.body).to eq "class Var; "
      expect(agent_source.status).to eq :error
      expect(agent_source.error).not_to eq nil
    end
    
    it "有効なコードに変更できる" do
      agent_source = Jiji::Model::Agents::AgentSource.create(
            "test", :agent, Time.at(100), "memo", "class Var; ")
      
      agent_source.update("test2", Time.at(200), "memo", "class Foo; def to_s; return \"xxx\"; end; end")
      
      expect(agent_source._id).not_to be nil
      expect(agent_source.name).to eq "test2"
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq "memo"
      expect(agent_source.body).to eq "class Foo; def to_s; return \"xxx\"; end; end"
      expect(agent_source.status).to eq :normal
      expect(agent_source.error).to eq nil
      
      # 再読み込みしても同じ状態
      agent_source = @repository.get_by_id_with_body( agent_source._id )
      expect(agent_source.name).to eq "test2"
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq "memo"
      expect(agent_source.body).to eq "class Foo; def to_s; return \"xxx\"; end; end"
      expect(agent_source.status).to eq :normal
      expect(agent_source.error).to eq nil
    end
    
    it "無効なコードに変更した場合、エラーになる" do
      agent_source = Jiji::Model::Agents::AgentSource.create(
            "test", :agent, Time.at(100), "memo", "class Var; ")
      
      agent_source.update("test2", Time.at(200), "memo", "class Foo; ")
      
      expect(agent_source._id).not_to be nil
      expect(agent_source.name).to eq "test2"
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq "memo"
      expect(agent_source.body).to eq "class Foo; "
      expect(agent_source.status).to eq :error
      expect(agent_source.error).not_to eq nil
      
      # 再読み込みしても同じ状態
      agent_source = @repository.get_by_id_with_body( agent_source._id )
      expect(agent_source.name).to eq "test2"
      expect(agent_source.type).to eq :agent
      expect(agent_source.created_at).to eq Time.at(100)
      expect(agent_source.updated_at).to eq Time.at(200)
      expect(agent_source.memo).to eq "memo"
      expect(agent_source.body).to eq "class Foo; "
      expect(agent_source.status).to eq :error
      expect(agent_source.error).not_to eq nil
    end
  end
  
  it "読み込んだコードを利用できる" do
    agent_source = Jiji::Model::Agents::AgentSource.create(
        "test", :agent, Time.at(100), "memo", "class Foo; def to_s; return \"xxx\"; end; end")
    f = agent_source.context.const_get "Foo" 
    instance_f1 = f.new
    
    expect(instance_f1.to_s).to eq "xxx"
    
    
    agent_source.update("test2", Time.at(200), "memo", 
        "class Foo; def to_s; return \"xxx2\"; end; end;" \
      + "class Var; def to_s; return \"var\";  end; end;")
    
    f2 = agent_source.context.const_get "Foo" 
    instance_f2 = f2.new
    v2 = agent_source.context.const_get "Var" 
    instance_v2 = v2.new
    
    expect(instance_f1.to_s).to eq "xxx"
    expect(instance_f2.to_s).to eq "xxx2"
    expect(instance_v2.to_s).to eq "var"
    
    
    agent_source.update("test2", Time.at(200), "memo", "class Foo;")
    
    expect(instance_f1.to_s).to eq "xxx"
    expect(instance_f2.to_s).to eq "xxx2"
    expect(instance_v2.to_s).to eq "var"
  end
  
  it "リークしない" do
    agent_source = Jiji::Model::Agents::AgentSource.create(
        "test", :agent, Time.at(100), "memo", "class Foo; def to_s; return \"xxx\"; end; end")

    #100000.times {|i|
    10.times {|i|
      agent_source.update("test2", Time.at(200), "memo", 
          "class Foo; def to_s; return \"xxx2\"; end; end;" \
        + "class Var; def to_s; return \"var\";  end; end;")
      f = agent_source.context.const_get "Foo" 
      instance_f = f.new
    }
  end
  
end