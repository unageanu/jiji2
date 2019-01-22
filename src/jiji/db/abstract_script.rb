# frozen_string_literal: true

require 'encase'

module Jiji::Db
  class AbstractScript

    include Encase

    def call(status, logger); end

    def create_id(file)
      dir = File.dirname(file)
      File.basename(dir) + '/' + File.basename(file, '.*')
    end

  end
end
