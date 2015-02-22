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

  def not_found(type = nil, param = nil)
    fail Jiji::Errors::NotFoundException.new(
      "#{type || 'entity'} is not found. #{to_string(param)}")
  end

  def illegal_state(msg = '', param = nil)
    fail Jiji::Errors::IllegalStateException.new(
      msg +  ' ' + to_string(param))
  end

  def illegal_argument(msg = '', param = nil)
    fail ArgumentError.new(msg + ' ' + to_string(param))
  end

  def already_exists(type = nil, param = nil)
    fail AlreadyExistsException.new(
      "#{type || 'entity'} already exists. #{to_string(param)}")
  end

  def to_string(param)
    return '' if param.nil?
    param.map { |v| v.join('=') }.join(' ')
  end
end
