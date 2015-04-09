# coding: utf-8

module Jiji::Services
  class CryptographicService

    include Jiji::Errors

    def encrypt(text, secret = default_secret)
      new_encryptor(secret).encrypt_and_sign(text)
    end

    def decrypt(encrypted_text, secret = default_secret)
      new_encryptor(secret).decrypt_and_verify(encrypted_text)
    end

    private

    def new_encryptor(secret)
      ActiveSupport::MessageEncryptor.new(secret)
    end

    def default_secret
      ENV['SECRET'] \
      || illegal_state('environment variable $SECRET is not set.')
    end

  end
end
