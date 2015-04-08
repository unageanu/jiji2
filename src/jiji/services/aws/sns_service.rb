# coding: utf-8

require 'aws-sdk'
require 'jiji/errors/errors'

module Jiji::Services::AWS
  class SNSService

    include Jiji::Errors

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
      Aws::Credentials.new(ACCESS_KEY, SECRET_KEY)
    end

    REGION     = 'ap-northeast-1'

    ACCESS_KEY = 'AKIAJQWUGPKGTGCLLTOA'
    SECRET_KEY = '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'
    GCM_ARN    = 'arn:aws:sns:ap-northeast-1:452935723537:app/GCM/jiji2-gcm'

  end
end
