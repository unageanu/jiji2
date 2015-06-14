# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web::Test
  class MailService < Jiji::Web::AuthenticationRequiredService

    options '/' do
      allow('GET,OPTIONS')
    end

    get '/' do
      deliveries = Mail::TestMailer.deliveries.map do |mail|
        {
          subject: mail.subject,
          to:      mail.to,
          body:    mail.text_part.body.to_s
        }
      end
      Mail::TestMailer.deliveries.clear
      ok(deliveries)
    end

  end
end
