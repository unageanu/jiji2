# frozen_string_literal: true

require 'singleton'
require 'logger'
require 'fileutils'
require 'thread/pool'
require 'encase/container'

require 'jiji/composing/configurators/root_configurator'

module Jiji::Composing
  class ContainerFactory

    include Singleton

    def new_container
      container = Encase::Container.new
      configure(container)
      container
    end

    private

    def configure(container)
      Configurators::RootConfigurator.new.configure(container)
    end

  end
end
