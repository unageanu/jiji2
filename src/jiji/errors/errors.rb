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

end
end
