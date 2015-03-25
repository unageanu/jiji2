# coding: utf-8

require 'encase'
require 'jiji/errors/errors'
require 'lru_redux'

module Jiji::Security
  class SessionStore

    include Encase

    needs :time_source

    def initialize
      @sessions = LruRedux::ThreadSafeCache.new(100)
    end

    def <<(session)
      @sessions[session.token] = session
    end

    def invalidate(token)
      @sessions.delete token
    end

    def new_session(expiration_date, *authorities)
      session = Jiji::Security::Session.new(expiration_date, *authorities)
      self << session
      session
    end

    def valid_token?(token, required_authority = nil)
      s = @sessions[token]
      return false if s.nil? || s.expired?(time_source.now)
      return false if required_authority && !s.has?(required_authority)
      true
    end

  end
end
