# coding: utf-8

module Jiji::Composing::Configurators
  class PluginsConfigurator < AbstractConfigurator

    include Jiji::Plugin

    def configure(container)
      container.configure do
        object :plugin_loader, Loader.new
      end
    end

  end
end
