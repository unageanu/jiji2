# coding: utf-8

module Jiji::Composing::Configurators
  class ServicesConfigurator < AbstractConfigurator

    include Jiji::Services

    def configure(container)
      container.configure do
        object :cryptographic_service, CryptographicService.new
        object :imaging_service,       ImagingService.new
        object :sns_service,           AWS::SNSService.new
      end
    end

  end
end
