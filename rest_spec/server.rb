# coding: utf-8

ENV['ENABLE_COVERADGE_REPORT'] = 'false'

require 'singleton'
require 'fileutils'
require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'

module Jiji
  class Server

    include Singleton

    def initilize
      @running = false
    end

    def setup(id)
      return if @running

      initialize_db
      pid = start_server(id)
      register_shutdown_fook(pid)

      @running = true
    end

    private

    def initialize_db
      Jiji::Test::DataBuilder.new.clean
    end

    def start_server(id)
      log_dir = File.join(BUILD_DIR, 'rest_spec')
      FileUtils.mkdir_p log_dir
      pid = spawn(
        { 'RACK_ENV' => 'test' },
        'bundle exec puma -C config/puma.rb',
        out: File.join(log_dir, "test_server_#{id}.log"), err: :out)
      puts "start server pid=#{pid}"
      sleep 10
      pid
    end

    def register_shutdown_fook(pid)
      at_exit do
        fail "failed to kill server. pid=#{pid}" unless system("kill #{pid}")
        puts "stop server pid=#{pid}"
      end
    end

  end
end
