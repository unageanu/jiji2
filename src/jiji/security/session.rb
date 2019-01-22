# frozen_string_literal: true

require 'jiji/errors/errors'
require 'bcrypt'
require 'securerandom'

module Jiji::Security
  class Session

    def initialize(expires, *authorities)
      @token       = generate_token
      @expires     = expires
      @authorities = authorities || []
    end

    def expired?(now)
      @expires < now
    end

    def has?(authority)
      authorities.any? { |a| a == authority }
    end

    attr_reader :token, :expires, :authorities

    private

    def generate_token
      SecureRandom.hex(32)
    end

  end
end
