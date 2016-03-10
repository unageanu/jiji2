
require 'jiji/db/abstract_script'
require 'jiji/utils/requires'

module Jiji::Db
  class CreateCappedCollections < AbstractScript

    include Jiji::Model::Notification

    def initialize(config)
      @config = config
    end

    def id
      create_id(__FILE__)
    end

    def call(status, logger)
      client = SchemeStatus.mongo_client
      @config.each do |k, v|
        client[k, { capped: true }.merge(v)].create
      end
    end

  end
end
