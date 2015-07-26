# coding: utf-8

require 'encase'
require 'jiji/configurations/mongoid_configuration'
require 'jiji/model/settings/abstract_setting'

module Jiji::Model::Settings
  class SecuritiesSetting < AbstractSetting

    include Jiji::Errors
    include Encase
    include Mongoid::Document

    field :active_securities_id,      type: Symbol,  default: nil
    field :securities_configurations, type: Hash,    default: {}

    needs :logger_factory
    needs :securities_factory
    needs :securities_provider
    needs :rmt

    def initialize
      super
      self.category = :securities
    end

    def setup
      @logger = logger_factory.create
      return unless active_securities_id
      begin
        securities = find_and_configure_securities(
          active_securities_id, get_configurations(active_securities_id))
        securities_provider.set(securities)

      rescue Jiji::Errors::NotFoundException => e
        @logger.error(e) if @logger
      end
    end

    def get_configurations(securities_id)
      securities_factory.get(securities_id)
      securities_configurations[securities_id] || {}
    end

    def set_active_securities(securities_id, configurations)
      securities = find_and_configure_securities(
        securities_id, configurations)

      self.active_securities_id = securities_id
      securities_configurations[securities_id] = configurations
      save

      rmt.process.post_exec do |_context, _queue|
        securities_provider.set(securities)
      end.value

      fire_setting_changed_event(:active_securities, value: securities)
    end

    private

    def find_and_configure_securities(securities_id, configurations)
      configurations = configurations.with_indifferent_access
      securities_factory.create(securities_id, configurations)
    rescue Jiji::Errors::NotFoundException
      raise
    rescue Exception => e  # rubocop:disable Lint/RescueException
      @logger.error(e) if @logger
      illegal_argument('failed to connect securities.')
    end

  end
end
