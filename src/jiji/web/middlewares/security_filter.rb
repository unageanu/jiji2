# coding: utf-8

require 'sinatra/base'
require 'jiji/web/middlewares/base'

module Jiji::Web
  class SecurityFilter < Base

    before do
      headers(@headers ||= {
        'X-Frame-Options'                   => 'SAMEORIGIN',
        'X-Content-Type-Options'            => 'nosniff',
        'Content-Security-Policy'           => 'default-src \'self\'; ' \
            + 'style-src \'self\' fonts.googleapis.com maxcdn.bootstrapcdn.com \'unsafe-inline\'; ' \
            + 'font-src  \'self\' fonts.googleapis.com maxcdn.bootstrapcdn.com fonts.gstatic.com;',
        'X-Download-Options'                => 'noopen',
        'X-Permitted-Cross-Domain-Policies' => 'master-only',
        'X-XSS-Protection'                  => '1; mode=block'
      })
    end

  end
end
