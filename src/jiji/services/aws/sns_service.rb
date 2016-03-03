# coding: utf-8

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
      return yield
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

    REGION     = 'ap-northeast-1'.freeze

    SECRET     = '49+$sAa87fLLcU6x)(MNi|WC3C725_G/tP5tfStU' \
                 + 'cz6$)R/*!Li2v4XVcSt-hA#B*-)%tL9N'
    ACCESS_KEY = 'QzJyQjBrbHVpNmRwdVM4bTRDbzBLQXZCVlNET0lkOXhwNWxIOWt1NGl6T' \
                 + 'T0tLVRqcGk4UFgxZHRDUG1Gd3U0a0lSR1E9PQ==--caa3b860a406ef' \
                 + '7c4e0ab44dcfaea57b85760d9c'
    SECRET_KEY = 'QTBteWwxOHo5NXQ5NG0rZ3lNNEJlWlRIS3hIcVVxaG14TGd2Qk9RcHptc' \
                 + 'GtxLzVPbmZiNEJpV2RtZTl5NFc0MXk1a2Ura1pHeXgyWWh4YS9XMTR0' \
                 + 'alE9PS0ta0IxWmhpRXdpazZoRm1ISW5ZblVBdz09--0ac7362604ddb' \
                 + 'e30c782b9e1ddec55edb9a48617'
    GCM_ARN    = 'arn:aws:sns:ap-northeast-1:452935723537:app/GCM/jiji2-gcm'.freeze

  end
end
