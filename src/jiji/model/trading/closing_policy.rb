# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/web/transport/transportable'
require 'jiji/errors/errors'

module Jiji::Model::Trading
  class ClosingPolicy

    include Mongoid::Document
    include Jiji::Errors
    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable
    include Utils

    field :take_profit,     type: Float, default: 0
    field :stop_loss,       type: Float, default: 0
    field :trailing_stop,   type: Float, default: 0
    field :trailing_amount, type: Float, default: 0

    def to_h
      {
        take_profit:     take_profit,
        stop_loss:       stop_loss,
        trailing_stop:   trailing_stop,
        trailing_amount: trailing_amount
      }
    end

    def self.create(options)
      ClosingPolicy.new do |c|
        c.take_profit     = options[:take_profit]     || 0
        c.stop_loss       = options[:stop_loss]       || 0
        c.trailing_stop   = options[:trailing_stop]   || 0
        c.trailing_amount = options[:trailing_amount] || 0
      end
    end

    def extract_options_for_modify
      {
        stop_loss:     stop_loss,
        take_profit:   take_profit,
        trailing_stop: trailing_stop
      }
    end

    def close?(position)
      false # TODO
    end

    private

    def values
      [
        take_profit,   stop_loss,
        trailing_stop, trailing_amount
      ]
    end

  end
end
