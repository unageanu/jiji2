# coding: utf-8

module Jiji::Model::Securities
  class NilSecurities

    include Jiji::Errors

    def method_missing(method_name)
      not_initialized
    end

  end
end
