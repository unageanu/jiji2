# coding: utf-8

module Jiji::Composing::Configurators
  class DBConfigurator < AbstractConfigurator

    include Jiji::Db

    def configure(container)
      container.configure do
        object :index_builder, IndexBuilder.new
      end

      configure_migration_components(container)
    end

    private

    def configure_migration_components(container)
      container.configure do
        object :migrator, Migrator.new
        object :v0to1_register_system_agent, RegisterSystemAgents.new
      end
    end

  end
end
