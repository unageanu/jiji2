# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/composing/container_factory'

describe Jiji::Services::CryptographicService do
  before do
    @default_secret = ENV['SECRET']
    @default_user_secret = ENV['USER_SECRET']
  end

  after do
    ENV['SECRET'] = @default_secret
    ENV['USER_SECRET'] = @default_user_secret
  end

  it 'SECRET で 暗号化/復号化ができる' do
    service = Jiji::Services::CryptographicService.new

    value = service.encrypt('aaa')
    expect(service.decrypt(value)).to eq 'aaa'

    ENV['SECRET'] = 'a' * 100
    ENV['USER_SECRET'] = nil

    expect do
      service.decrypt(value)
    end.to raise_exception(ActiveSupport::MessageVerifier::InvalidSignature)

    value = service.encrypt('aaa')
    expect(service.decrypt(value)).to eq 'aaa'
  end

  it 'USER_SECRET で 暗号化/復号化ができる' do
    service = Jiji::Services::CryptographicService.new

    value = service.encrypt('aaa')
    expect(service.decrypt(value)).to eq 'aaa'

    ENV['SECRET'] = nil
    ENV['USER_SECRET'] = 'a'

    expect do
      service.decrypt(value)
    end.to raise_exception(ActiveSupport::MessageVerifier::InvalidSignature)

    value = service.encrypt('aaa')
    expect(service.decrypt(value)).to eq 'aaa'
  end

  it 'SECRET or USER_SECRET が未設定の場合、エラーになる' do
    service = Jiji::Services::CryptographicService.new
    value = service.encrypt('aaa')

    ENV['SECRET'] = nil
    ENV['USER_SECRET'] = nil

    expect do
      service.encrypt('aaa')
    end.to raise_exception(Jiji::Errors::IllegalStateException)

    expect do
      service.decrypt(value)
    end.to raise_exception(Jiji::Errors::IllegalStateException)
  end
end
