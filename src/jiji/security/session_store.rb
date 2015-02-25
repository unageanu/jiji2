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
      @sessions['f'] = Session.new(Time.now + 1 * 60 * 60 * 24)
    end

    def <<(session)
      @sessions[session.token] = session
    end

    def delete(token)
      @sessions.delete token
    end

    def valid_token?(token)
      s = @sessions[token]
      !s.nil? && !s.expired?(time_source.now)
    end

  end
end
