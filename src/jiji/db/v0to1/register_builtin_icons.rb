# frozen_string_literal: true

require 'encase'
require 'jiji/db/abstract_script'
require 'jiji/utils/requires'

module Jiji::Db
  class RegisterBuiltinIcons < AbstractScript

    needs :icon_repository

    def id
      create_id(__FILE__)
    end

    def call(status, logger)
      root = Jiji::Utils::Requires.root
      %w[icon01 icon02 icon03 icon04].each do |file|
        register_icon(
          "#{root}/src/jiji/model/icons/builtin_files/#{file}.png")
      end
    end

    def register_icon(file)
      @icon_repository.add(IO.read(file))
    end

  end
end
