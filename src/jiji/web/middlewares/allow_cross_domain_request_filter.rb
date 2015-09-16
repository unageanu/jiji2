# coding: utf-8

require 'sinatra/base'
require 'jiji/web/middlewares/base'

module Jiji::Web
  class AllowCrossDomainRequestFilter < Base

    before do
      if AllowCrossDomainRequestFilter.allow_cross_domain_request?
        headers({
          'Access-Control-Allow-Origin' => '*',
          'Access-Control-Max-Age'      => 10 * 24 * 60 * 60
        })
      end
    end

    def self.allow_cross_domain_request?
      ENV['RACK_ENV'] != 'production'
    end

  end
end
