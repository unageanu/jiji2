# coding: utf-8

ENV['ENABLE_COVERADGE_REPORT'] = 'false'

require 'singleton'
require 'fileutils'
require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'
require 'client'

module Jiji
  class Server

    include Singleton

    def initialize
      @running = false
    end

    def setup(id)
      return if @running

      initialize_db
      pid = start_server(id)
      puts "start server pid=#{pid}"

      register_shutdown_fook(pid)

      @running = true
    end

    private

    def initialize_db
      Jiji::Test::DataBuilder.new.clean
    end

    def start_server(id)
      log_dir = create_log_dir
      spawn(
        { 'RACK_ENV' => 'test', 'PORT' => '3000' },
        'bundle exec puma -C config/puma.rb',
        out: File.join(log_dir, "test_server_#{id}.log"), err: :out)
    end

    def create_log_dir
      log_dir = File.join(BUILD_DIR, 'rest_spec')
      FileUtils.mkdir_p log_dir
      log_dir
    end

    def register_shutdown_fook(pid)
      at_exit do
        raise "failed to kill server. pid=#{pid}" unless system("kill #{pid}")
        puts "stop server pid=#{pid}"
      end
    end

    def self.start_jiji_server(transport)
      Jiji::Client.instance.transport = transport == "json" \
        ? Jiji::Client::JsonTransport.new \
        : Jiji::Client::MessagePackTransport.new
      Jiji::Server.instance.setup(transport)

      Jiji::Client.instance.wait_for_server_start_up
    end

  end
end
