# coding: utf-8

require 'jiji/configurations/mongoid_configuration'

module Jiji::Db
  class SchemeStatus

    include Mongoid::Document

    store_in collection: 'scheme_status'

    field :status, type: Hash, default: {}

    def self.load
      SchemeStatus.first_or_create
    end

    def mark_as_applied(id)
      status[id] = true
    end

    def applied?(id)
      status[id] == true
    end

  end
end
