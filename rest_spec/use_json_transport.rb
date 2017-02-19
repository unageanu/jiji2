# coding: utf-8
require 'server'
require 'python_rpc_server'

Jiji::PythonRpcServer.start_python_rpc_server
Jiji::Server.start_jiji_server('json')

require 'all_specs'
