# coding: utf-8

require 'sinatra/base'
require 'jiji/web/middlewares/base'

module Jiji::Web
  FONT_AND_STYLE_SRC = '\'self\' fonts.googleapis.com maxcdn.bootstrapcdn.com'

  class SecurityFilter < Base

    before do
      headers(@headers ||= {
        'X-Frame-Options'                   => 'SAMEORIGIN',
        'X-Content-Type-Options'            => 'nosniff',
        'Content-Security-Policy'           => 'default-src \'self\'; ' \
            + 'style-src ' + FONT_AND_STYLE_SRC + ' \'unsafe-inline\'; ' \
            + 'font-src  ' + FONT_AND_STYLE_SRC + ' fonts.gstatic.com;',
        'X-Download-Options'                => 'noopen',
        'X-Permitted-Cross-Domain-Policies' => 'master-only',
        'X-XSS-Protection'                  => '1; mode=block'
      })
    end

  end
end
