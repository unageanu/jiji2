# coding: utf-8
require 'python_rpc_server'
require 'rpc_client'

Jiji::PythonRpcServer.instance.setup('python_rpc')
Jiji::RpcClient.instance.wait_for_server_start_up

require 'agent_service_spec'
