# frozen_string_literal: true

require 'rspec/mocks/standalone'
require 'jiji/composing/container_factory'
require 'jiji/test/mock/mock_securities'

module Jiji::Test
  class TestContainerFactory < Jiji::Composing::ContainerFactory

    include Jiji::Model

    def new_container
      container = super
      activate_mock_securities(container)
      container
    end

    def configure(container)
      super
      container.configure do
        mock = RSpec::Mocks::Double.new('sns_service', {
          register_platform_endpoint: 'target_arn',
          publish:                    'message_id'
        })
        object :sns_service, mock
      end
    end

    def activate_mock_securities(container)
      factory  = container.lookup(:securities_factory)
      provider = container.lookup(:securities_provider)

      Mock::MockSecurities.register_securities_to factory
      provider.set(factory.create(:MOCK))
    end

  end
end
