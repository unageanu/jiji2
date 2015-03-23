# coding: utf-8

require 'encase'
require 'jiji/configurations/mongoid_configuration'
require 'jiji/model/settings/abstract_setting'

module Jiji::Model::Settings
  class MailComposerSetting < AbstractSetting

    include Encase

    needs :cryptographic_service

    field :smtp_host,           type: String,  default: nil
    field :smtp_port,           type: Integer, default: 587
    field :encrypted_user_name, type: String,  default: nil
    field :encrypted_password,  type: String,  default: nil

    def initialize
      super
      self.category = :mail_composer
    end

    def self.load_or_create
      find(:mail_composer) || MailComposerSetting.new
    end

    def password
      encrypted_password \
      && cryptographic_service.decrypt(encrypted_password)
    end

    def password=(password)
      self.encrypted_password =
        cryptographic_service.encrypt(password)
    end

    def user_name
      encrypted_user_name \
      && cryptographic_service.decrypt(encrypted_user_name)
    end

    def user_name=(user_name)
      self.encrypted_user_name =
        cryptographic_service.encrypt(user_name)
    end

  end
end
