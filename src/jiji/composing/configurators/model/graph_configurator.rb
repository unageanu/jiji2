# coding: utf-8

module Jiji::Composing::Configurators
  class GraphConfigurator < AbstractConfigurator

    include Jiji::Model::Graphing

    def configure(container)
      container.configure do
        object :graph_repository, GraphRepository.new
      end
    end

  end
end
