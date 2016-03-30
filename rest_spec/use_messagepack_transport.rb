# coding: utf-8
require 'server'
require 'client'

Jiji::Server.instance.setup('msgpack')
Jiji::Client.instance.wait_for_server_start_up

require 'all_specs'
