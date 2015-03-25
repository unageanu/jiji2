# coding: utf-8

module Jiji::Composing::Configurators
  class SecurityConfigurator < AbstractConfigurator

    include Jiji::Security

    def configure(container)
      container.configure do
        object :authenticator,     Authenticator.new
        object :session_store,     SessionStore.new
        object :password_resetter, PasswordResetter.new
      end
    end

  end
end
