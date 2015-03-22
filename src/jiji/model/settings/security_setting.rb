# coding: utf-8

require 'encase'
require 'bcrypt'
require 'jiji/configurations/mongoid_configuration'
require 'jiji/model/settings/abstract_setting'

module Jiji::Model::Settings
  class SecuritySetting < AbstractSetting

    include Encase

    field :encrypted_mail_address, type: String, default: nil
    field :salt,                   type: String, default: nil
    field :hashed_password,        type: String, default: nil
    field :expiration_days,        type: Integer, default: 10

    needs :cryptographic_service

    def initialize
      super
      self.category = :security
    end

    def self.load_or_create
      find(:security) || SecuritySetting.new
    end

    def password_setted?
      !(salt && hashed_password).nil?
    end

    def mail_address
      encrypted_mail_address \
      && cryptographic_service.decrypt(encrypted_mail_address)
    end

    def mail_address=(mail_address)
      self.encrypted_mail_address =
        cryptographic_service.encrypt(mail_address)
    end

    def password=(password)
      self.salt = new_salt
      self.hashed_password = hash(password, salt)
    end

    def hash(password, salt)
      BCrypt::Engine.hash_secret(password, salt)
    end

    private

    def new_salt
      BCrypt::Engine.generate_salt
    end

  end
end
