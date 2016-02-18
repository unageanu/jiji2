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
      || (ENV['USER_SECRET'] && sha256(ENV['USER_SECRET'])) \
      || illegal_state('environment variable $SECRET ' \
          + 'or $ USER_SECRET is not set.')
    end

    def sha256(src)
      OpenSSL::Digest::SHA256.new(src).digest
    end

  end
end
