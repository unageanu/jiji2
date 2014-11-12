# coding: utf-8

require 'jiji/errors/errors'
require 'lru_redux'

module Jiji
module Security

  class SessionStore
    
    include Encase

    needs :time_source
    
    def initialize( )
      @sessions = LruRedux::ThreadSafeCache.new(100)
    end
    
    def << ( session )
      @sessions[session.token] = session
    end
    
    def delete( token )
      @sessions.delete token
    end
    
    def valid_token?( token )
      s = @sessions[token]
      return s != nil && !s.expired?( time_source.now )
    end
  
  end

end
end