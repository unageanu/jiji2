# coding: utf-8

module Jiji::Errors
  class AuthFailedException < StandardError

    def http_status
      401
    end

  end

  class NotFoundException < StandardError

    def http_status
      404
    end

  end

  class UnauthorizedException < StandardError

    def http_status
      401
    end

  end

  class NotInitializedException < StandardError

    def http_status
      400
    end

  end

  class IllegalStateException < StandardError

    def http_status
      400
    end

  end

  class InternalServerError < StandardError

    def http_status
      500
    end

  end

  class AlreadyExistsException < StandardError

    def http_status
      400
    end

  end

  class UnsupportedOperationException < StandardError

    def http_status
      500
    end

  end

  def not_initialized
    fail Jiji::Errors::NotInitializedException
  end

  def auth_failed
    fail Jiji::Errors::AuthFailedException
  end

  def unauthorized
    fail Jiji::Errors::UnauthorizedException
  end

  def not_found(type = nil, param = nil)
    fail Jiji::Errors::NotFoundException,
      "#{type || 'entity'} is not found. #{to_string(param)}"
  end

  def illegal_state(msg = '', param = nil)
    fail Jiji::Errors::IllegalStateException,
      msg +  ' ' + to_string(param)
  end

  def illegal_argument(msg = '', param = nil)
    fail ArgumentError, msg + ' ' + to_string(param)
  end

  def already_exists(type = nil, param = nil)
    fail AlreadyExistsException,
      "#{type || 'entity'} already exists. #{to_string(param)}"
  end

  def unsupported
    fail UnsupportedOperationException
  end

  def internal_server_error(exception)
    fail InternalServerError, exception.to_s
  end

  def to_string(param)
    return '' if param.nil?
    param.map { |v| v.join('=') }.join(' ')
  end
end
