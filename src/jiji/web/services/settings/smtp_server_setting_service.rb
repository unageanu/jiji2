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
        password:  mail_setting.password
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
        enable_postmark: (postmark_smtp_server.available? == true)
      })
    end

    options '/test' do
      allow('POST,OPTIONS')
    end

    post '/test' do
      body = load_body
      mail_address = body['mail_address'] || security_setting.mail_address
      server_setting = load_smtp_server_setting(body)
      mail_composer.compose_test_mail(mail_address, server_setting)
      no_content
    end

    def load_smtp_server_setting(body)
      return nil unless body.include? 'smtp_host'
      {
        address:   body['smtp_host'],
        port:      body['smtp_port'],
        domain:    Jiji::Messaging::MailComposer::DOMAIN,
        user_name: body['user_name'],
        password:  body['password']
      }
    end

    def postmark_smtp_server
      lookup(:postmark_smtp_server)
    end

    def mail_composer
      lookup(:mail_composer)
    end

    def setting
      lookup(:setting_repository).mail_composer_setting
    end

    def security_setting
      lookup(:setting_repository).security_setting
    end

  end
end
