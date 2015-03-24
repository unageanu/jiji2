# coding: utf-8
require 'client'
require 'server'

Jiji::Client.instance.transport = Jiji::Client::JsonTransport.new
Jiji::Server.instance.setup('json')

require 'all_specs'
