# frozen_string_literal: true

module Jiji::Model::Securities
  class NilSecurities

    include Jiji::Errors

    def method_missing(method_name, *args)
      not_initialized
      super
    end

    def respond_to_missing?(symbol, include_private)
      true
    end

    def destroy; end

  end
end
