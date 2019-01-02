# frozen_string_literal: true

require 'server'
require 'client'

Jiji::Client.instance.transport = Jiji::Client::JsonTransport.new
Jiji::Server.instance.setup('json')

Jiji::Client.instance.wait_for_server_start_up

require 'all_specs'
