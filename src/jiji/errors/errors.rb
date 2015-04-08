# coding: utf-8

module Jiji::Errors
  class AuthFailedException < Exception

  end

  class NotFoundException < Exception

  end

  class UnauthorizedException < Exception

  end

  class NotInitializedException < Exception

  end

  class IllegalStateException < Exception

  end

  class InternalServerError < Exception

  end

  class AlreadyExistsException < Exception

  end

  def auth_failed
    fail Jiji::Errors::AuthFailedException
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

  def internal_server_error(exception)
    fail InternalServerError, exception.to_s
  end

  def to_string(param)
    return '' if param.nil?
    param.map { |v| v.join('=') }.join(' ')
  end
end
