# coding: utf-8

require 'rpc_client'

describe 'AgentService' do
  before(:example) do
    @stub = Jiji::RpcClient.instance.agent_service
  end

  describe '#register' do

    it 'can register agent source file' do
      source = Jiji::Rpc::AgentSource.new(name: "test" , body:"")
      result = @stub.register(source)
    end

  end
end
