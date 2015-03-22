# coding: utf-8

module Jiji::Services
  class CryptographicService

    include Jiji::Errors

    def encrypt(text)
      new_encryptor.encrypt_and_sign(text)
    end

    def decrypt(encrypted_text)
      new_encryptor.decrypt_and_verify(encrypted_text)
    end

    private

    def new_encryptor
      ActiveSupport::MessageEncryptor.new(secret)
    end

    def secret
      ENV['SECRET'] \
      || illegal_state('environment variable $SECRET is not set.')
    end

  end
end
