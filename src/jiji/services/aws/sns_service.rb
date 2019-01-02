# frozen_string_literal: true

require 'encase'
require 'aws-sdk'
require 'jiji/errors/errors'

module Jiji::Services::AWS
  class SNSService

    include Encase
    include Jiji::Errors

    needs :cryptographic_service

    def register_platform_endpoint(type, token)
      run do
        client.create_platform_endpoint({
          platform_application_arn: GCM_ARN,
          token:                    token
        })[:endpoint_arn]
      end
    end

    def publish(target_arn, message, subject)
      run do
        client.publish(
          target_arn:        target_arn,
          message:           message,
          subject:           subject,
          message_structure: 'json'
        )[:message_id]
      end
    end

    def client
      Aws::SNS::Client.new(region: REGION, credentials: credentials)
    end

    private

    def run(&block)
      yield
    rescue Aws::SNS::Errors::ServiceError => e
      internal_server_error(e)
    end

    def credentials
      @credentials ||= Aws::Credentials.new(
        decrypt(ACCESS_KEY), decrypt(SECRET_KEY))
    end

    def decrypt(src)
      @cryptographic_service.decrypt(src, SECRET)
    end

    REGION     = 'ap-northeast-1'

    SECRET     = '49+$sAa87fLLcU6x)(MNi|WC3C725_G/tP5tfStU' \
                 + 'cz6$)R/*!Li2v4XVcSt-hA#B*-)%tL9N'
    ACCESS_KEY = 'dE1QeitrWGRvQmdIWW4wRkViWFB6Nmw2ZEFRM0NDaWRaVWJ4emhoM3JDWT0tLUVrUlFzKy9BaVM4dzI2YjY5REhETnc9PQ==--8b8fd48e26bebf5a3f9137118bf86c05d857849d'
    SECRET_KEY = 'Y0FTUzFDNnJwV0dxNnZNOEJRL2NSWVBCdDFMYUJ4WURWa2o0UHlIZzE5U2ZOZXNhOUxkS0p4S2hPN1lBMkZSbXFFQXhWWUZaSmI0YlI0cGh5NjNnWUE9PS0tMnB0b0xDMXVIb0pYVldzRWtROG5nQT09--3429708a79ee71f4dc9de6b792ff94ade747eb84'
    GCM_ARN    = 'arn:aws:sns:ap-northeast-1:452935723537:app/GCM/jiji2-gcm' \


  end
end
