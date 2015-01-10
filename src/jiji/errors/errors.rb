# coding: utf-8

module Jiji
module Errors

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
  
  def not_found(type=nil, param=nil)
    raise Jiji::Errors::NotFoundException.new( 
      "#{type || 'entity'} is not found. #{to_string(param)}" )
  end
  
  def illegal_state(msg="", param=nil)
    raise Jiji::Errors::IllegalStateException.new(
      msg +  " " + to_string(param))
  end
  
  def illegal_argument(msg="", param=nil)
    raise ArgumentError.new(msg + " " + to_string(param))
  end
  
  def to_string(param)
    return "" if param == nil
    param.map{|v| v.join("=") }.join(" ")
  end
  
end
end
