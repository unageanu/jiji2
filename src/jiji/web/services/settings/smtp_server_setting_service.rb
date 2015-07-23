# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class SMTPServerSettingService < Jiji::Web::AbstractService

    options '/' do
      allow('GET,PUT,OPTIONS')
    end

    get '/' do
      mail_setting = setting
      ok({
        smtp_host: mail_setting.smtp_host,
        smtp_port: mail_setting.smtp_port,
        user_name: mail_setting.user_name,
        password:  Jiji::Utils::Strings.mask(mail_setting.password)
      })
    end

    put '/' do
      body = load_body
      mail_setting = setting
      mail_setting.smtp_host = body['smtp_host']
      mail_setting.smtp_port = body['smtp_port'].to_i
      mail_setting.user_name = body['user_name']
      mail_setting.password  = body['password']
      mail_setting.save
      no_content
    end

    options '/status' do
      allow('GET,OPTIONS')
    end

    get '/status' do
      ok({
        enable_postmark: (postmarkSMTPServer.available? == true)
      })
    end

    options '/test' do
      allow('POST,OPTIONS')
    end

    post '/test' do
      compose_test_mail(load_body)
      no_content
    end

    def compose_test_mail(body)
      mail_composer.compose(to, '[Jiji] テストメール',
        Jiji::Messaging::MailComposer::FROM,
        load_smtp_server_setting_from( body )) do
          text_part do
            content_type 'text/plain; charset=UTF-8'
            body 'メール送信のテスト用メールです。'
          end
      end
    end

    def load_smtp_server_setting_from( body )
      {
        address:   body['smtp_host'],
        port:      body['smtp_port'],
        domain:    Jiji::Messaging::MailComposer::DOMAIN,
        user_name: body['user_name'],
        password:  body['password']
      }
    end

    def postmarkSMTPServer
      lookup(:postmarkSMTPServer)
    end
    def mail_composer
      lookup(:mail_composer)
    end
    def setting
      lookup(:setting_repository).mail_composer_setting
    end

  end
end
