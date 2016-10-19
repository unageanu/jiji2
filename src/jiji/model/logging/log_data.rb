# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/errors/errors'
require 'jiji/web/transport/transportable'

module Jiji::Model::Logging
  class LogData

    include Mongoid::Document
    include Jiji::Utils::BulkWriteOperationSupport
    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable
    include Jiji::Errors

    store_in collection: 'log_data'
    belongs_to :backtest, {
      class_name: 'Jiji::Model::Trading::BackTestProperties',
      optional:   true
    }

    field :body,          type: Array, default: []
    field :timestamp,     type: Time
    field :size,          type: Integer, default: 0

    index(
      { backtest_id: 1, timestamp: -1 },
      name: 'logdata_backtest_id_timestamp_index')

    def self.create(timestamp, body = nil, backtest_id = nil)
      LogData.new do |data|
        data.backtest_id = backtest_id
        data.timestamp = timestamp
        data << body if body
      end
    end

    def <<(data)
      body << data
      self.size += data.bytesize
    end

    def full?
      size >= 100 * 1024
    end

    def to_h
      {
        body:      body.join("\n"),
        timestamp: timestamp,
        size:      size
      }
    end

    def self.drop
      client = mongo_client
      client['log_data'].drop
    end

  end
end
