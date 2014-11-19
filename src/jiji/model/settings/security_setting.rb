# coding: utf-8

require 'bcrypt'
require 'jiji/utils/value_object'

module Jiji
module Model
module Settings

  class SecuritySetting
    
    include Mongoid::Document
    include Jiji::Utils::ValueObject
    
    store_in collection: "settings"
    
    field :category,        type: Symbol, default: :security
    field :salt,            type: String, default: nil
    field :hashed_password, type: String, default: nil
    field :expiration_days, type: Integer,default: 10
    
    def self.load_or_create
      find || SecuritySetting.new
    end
    
    def password=( password )
      self.salt = new_salt
      self.hashed_password = hash(password, salt)
    end
    
  private
    
    def self.find
      SecuritySetting.find_by( :category => :security )
    end
    
    def hash( password, salt )
      BCrypt::Engine.hash_secret( password, salt )
    end
  
    def new_salt
      BCrypt::Engine.generate_salt
    end
  
  end

end
end
end