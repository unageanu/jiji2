# frozen_string_literal: true

require 'encase'
require 'jiji/db/abstract_script'
require 'jiji/utils/requires'

module Jiji::Db
  class RegisterSystemAgents < AbstractScript

    needs :agent_registry

    def id
      create_id(__FILE__)
    end

    def call(status, logger)
      root = Jiji::Utils::Requires.root
      %w[signals moving_average_agent cross].each do |file|
        register_source(
          "#{root}/src/jiji/model/agents/builtin_files/#{file}.rb")
      end
    end

    def register_source(file)
      @agent_registry.add_source(
        File.basename(file), '', :agent, IO.read(file))
    end

  end
end
