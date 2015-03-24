# coding: utf-8
require 'server'
require 'client'

Jiji::Client.instance.transport = Jiji::Client::JsonTransport.new
Jiji::Server.instance.setup('json')

require 'all_specs'
