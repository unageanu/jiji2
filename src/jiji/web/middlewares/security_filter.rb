# frozen_string_literal: true

require 'sinatra/base'
require 'jiji/web/middlewares/base'

module Jiji::Web
  FONT_AND_STYLE_SRC = '\'self\' fonts.googleapis.com'
  NEWRELIC_SRC = ' *.newrelic.com bam.nr-data.net '
  GOOGLE_ANALYTICS_SRC = '*.google-analytics.com stats.g.doubleclick.net'

  class SecurityFilter < Base

    before do
      headers(@headers ||= {
        'X-Frame-Options' => 'SAMEORIGIN',
        'X-Content-Type-Options' => 'nosniff',
        'Content-Security-Policy' =>
              'default-src \'self\'; ' \
            + 'script-src ' + script_src + '; ' \
            + 'style-src ' + FONT_AND_STYLE_SRC + ' \'unsafe-inline\'; ' \
            + 'font-src  ' + FONT_AND_STYLE_SRC + ' fonts.gstatic.com; ' \
            + 'img-src \'self\' data: play.google.com ' + GOOGLE_ANALYTICS_SRC,
        'X-Download-Options' => 'noopen',
        'X-Permitted-Cross-Domain-Policies' => 'master-only',
        'X-XSS-Protection' => '1; mode=block'
      })
    end

    def script_src
      ' \'self\' \'unsafe-inline\' \'unsafe-eval\' ' \
        + NEWRELIC_SRC + ' ' + GOOGLE_ANALYTICS_SRC \
        + '; '
    end

  end
end
