# coding: utf-8

require 'rspec/mocks/standalone'
require 'jiji/composing/container_factory'

module Jiji::Test
  class TestContainerFactory < Jiji::Composing::ContainerFactory

    include Jiji::Model

    def configure(container)
      super
      container.configure do
        object :sns_service, double('sns_service', {
          register_platform_endpoint: 'target_arn',
          publish:                    'message_id'
        })
      end
    end

  end
end
