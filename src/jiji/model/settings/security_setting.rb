# coding: utf-8

require 'jiji/model/dao/setting'
require 'bcrypt'

module Jiji
module Model
module Settings

  class SecuritySetting
    
    def initialize
      @setting = find || new_setting
    end
    
    def password=( password )
      salt = new_salt
      values[:hashed_password] = hash(password, salt)
      values[:salt] = salt
    end
    
    def salt
      values[:salt]
    end
    
    def hashed_password
      values[:hashed_password]
    end
    
    def expiration_days
      values[:expiration_days]
    end
    
    def expiration_days=(value)
      values[:expiration_days]=value
    end
    
    def save
      @setting.save
    end

  private
    
    def values
      @setting[:values]
    end
    
    def find
      Jiji::Model::Dao::Setting.find_by( :category => "security" )
    end
    
    def new_setting
      Jiji::Model::Dao::Setting.new {|s|
        s.category = :security
        s.values   = {
          :expiration_days => 10,
          :salt            => nil,
          :hashed_password => nil
        }
      }
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