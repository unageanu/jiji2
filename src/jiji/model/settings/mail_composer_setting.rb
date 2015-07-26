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

    validates :smtp_host,
      length:      { maximum: 1000, strict: true },
      allow_nil:   true,
      allow_blank: true

    validates :smtp_port,
      numericality: {
        only_integer:             true,
        greater_than_or_equal_to: 0,
        strict:                   true
      }

    validates :user_name,
      length:      { maximum: 1000, strict: true },
      allow_nil:   true,
      allow_blank: true

    validates :password,
      length:      { maximum: 1000, strict: true },
      allow_nil:   true,
      allow_blank: true

    def initialize
      super
      self.category = :mail_composer
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
