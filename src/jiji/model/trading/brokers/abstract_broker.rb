# coding: utf-8

require 'jiji/configurations/mongoid_configuration'

module Jiji::Model::Trading::Brokers
  class AbstractBroker

    include Jiji::Model::Trading

    def initialize
      @positions = {}
    end

    attr_reader :positions

    def pairs
      @pairs_cache ||= retrieve_pairs
    end

    def tick
      @rates_cache ||= retrieve_tick
    end

    def close(position_id)
      check_position_exists(position_id)

      position = @positions[position_id]
      do_close(position)
      position.close

      @positions.delete position_id
    end

    def refresh
      @pairs_cache = nil
      @rates_cache = nil
      update_positions if next?
    end

    private

    def update_positions
      @positions.values.each do |p|
        p.update(tick)
      end
    end

    def create_position(pair_name, count, sell_or_buy, external_position_id)
      illegal_state('tick is not exists.') unless tick
      position = Position.create(@back_test_id, external_position_id,
        pair_name, count, 1, sell_or_buy, tick)
      @positions[position._id] = position
      position
    end

    def do_close(_position)
    end

    def check_position_exists(id)
      not_found(Position, id => id) unless @positions.include? id
    end

  end
end
