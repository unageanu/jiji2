# coding: utf-8

require 'bcrypt'
require 'jiji/configurations/mongoid_configuration'
require 'jiji/model/settings/abstract_setting'

module Jiji::Model::Settings
  class SecuritySetting < AbstractSetting
    field :salt,            type: String, default: nil
    field :hashed_password, type: String, default: nil
    field :expiration_days, type: Integer, default: 10

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
