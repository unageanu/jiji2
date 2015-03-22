# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/composing/container_factory'

describe Jiji::Services::CryptographicService do
  before do
    @default_secret = ENV['SECRET']
  end

  after do
    ENV['SECRET'] = @default_secret
  end

  it '暗号/復号ができる' do
    service = Jiji::Services::CryptographicService.new

    value = service.encrypt('aaa')
    expect(service.decrypt(value)).to eq 'aaa'

    ENV['SECRET'] = 'a' * 100
    expect do
      service.decrypt(value)
    end.to raise_exception(ActiveSupport::MessageVerifier::InvalidSignature)

    value = service.encrypt('aaa')
    expect(service.decrypt(value)).to eq 'aaa'
  end

  it 'SECRET が未設定の場合、エラーになる' do
    service = Jiji::Services::CryptographicService.new
    value = service.encrypt('aaa')

    ENV['SECRET'] = nil

    expect do
      service.encrypt('aaa')
    end.to raise_exception(Jiji::Errors::IllegalStateException)

    expect do
      service.decrypt(value)
    end.to raise_exception(Jiji::Errors::IllegalStateException)
  end
end
