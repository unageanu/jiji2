# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/composing/container_factory'

describe Jiji::Services::AWS::SNSService do
  before do
    @service = Jiji::Services::AWS::SNSService.new
    @service.cryptographic_service = Jiji::Services::CryptographicService.new
  end

  it 'デバイスを登録して、Push通知ができる' do
    target_arn = @service.register_platform_endpoint(:gcm, 'test')
    expect(target_arn).not_to be nil

    begin
      message_id = @service.publish(target_arn, 'test', '{foor:"var"}')
      expect(message_id).not_to be nil
    rescue Jiji::Errors::InternalServerError => e
      p e
    end
  end

  it 'エンドポイントの一覧取得などはできない' do
    expect do
      @service.client.list_endpoints_by_platform_application(
        { platform_application_arn: Jiji::Services::AWS::SNSService::GCM_ARN })
    end.to raise_exception(Aws::SNS::Errors::AuthorizationError)

    expect do
      @service.client.list_platform_applications
    end.to raise_exception(Aws::SNS::Errors::AuthorizationError)

    target_arn = @service.register_platform_endpoint(:gcm, 'test')
    expect do
      @service.client.delete_endpoint(endpoint_arn: target_arn)
    end.to raise_exception(Aws::SNS::Errors::AuthorizationError)
    expect do
      @service.client.delete_platform_application({
        platform_application_arn: Jiji::Services::AWS::SNSService::GCM_ARN
      })
    end.to raise_exception(Aws::SNS::Errors::AuthorizationError)
  end
end
