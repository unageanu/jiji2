# coding: utf-8

require 'jiji/errors/errors'
require 'bcrypt'
require 'securerandom'

module Jiji::Security
  class Session

    def initialize(expires)
      @token = generate_token
      @expires = expires
    end

    def expired?(now)
      @expires < now
    end

    attr_reader :token, :expires

    private

    def generate_token
      SecureRandom.hex(32)
    end

  end
end
