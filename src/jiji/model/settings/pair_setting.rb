# coding: utf-8

require 'encase'
require 'set'
require 'jiji/configurations/mongoid_configuration'
require 'jiji/model/settings/abstract_setting'

module Jiji::Model::Settings
  class PairSetting < AbstractSetting

    include Encase
    include Mongoid::Document

    needs :pairs

    field :pair_names, type: Array, default: []

    def initialize
      super
      self.category = :pair
    end

    def pairs_for_use
      set = Set.new(pair_names.empty? ? default_pair_names : pair_names)
      pairs.all.select { |p| set.include?(p.name.to_s) }
    end

    private

    def default_pair_names
      pairs.all.select { |p| p.name.to_s =~ /JPY/ }.map { |p| p.name.to_s }
    end

  end
end
