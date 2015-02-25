# coding: utf-8

require 'encase'
require 'jiji/configurations/mongoid_configuration'
require 'jiji/model/settings/abstract_setting'

module Jiji::Model::Settings
  class RMTBrokerSetting < AbstractSetting

    include Encase
    include Mongoid::Document

    field :active_securities_id,      type: Symbol,  default: nil
    field :securities_configurations, type: Hash,    default: {}
    field :is_trade_enabled,          type: Boolean, default: true

    attr_reader :active_securities

    needs :logger

    def initialize
      super
      self.category = :rmt_broker
    end

    def setup
      return unless active_securities_id
      begin
        @active_securities = find_and_configure_plugin(
          active_securities_id, get_configurations(active_securities_id))

      rescue Jiji::Errors::NotFoundException => e
        @logger.error(e) if @logger
      end
    end

    def self.load_or_create
      find(:rmt_broker) || RMTBrokerSetting.new
    end

    def self.available_securities
      JIJI::Plugin.get(JIJI::Plugin::SecuritiesPlugin::FUTURE_NAME)
    end

    def self.get_configuration_definitions(securities_id)
      resolve_plugin(securities_id).input_infos
    end

    def get_configurations(securities_id)
      RMTBrokerSetting.check_plugin_existence(securities_id)
      securities_configurations[securities_id]
    end

    def set_active_securities(securities_id, configurations)
      @active_securities = find_and_configure_plugin(
        securities_id, configurations)

      self.active_securities_id = securities_id
      securities_configurations[securities_id] = configurations
      save

      fire_setting_changed_event(:active_securities, value: @active_securities)
    end

    attr_writer :is_trade_enabled

    private

    def self.check_plugin_existence(securities_id)
      resolve_plugin(securities_id)
    end
    def find_and_configure_plugin(securities_id, configurations)
      configurations = configurations.with_indifferent_access
      plugin = RMTBrokerSetting.resolve_plugin(securities_id)
      plugin.init_plugin(configurations, @logger)
      plugin
    end
    def self.resolve_plugin(securities_id)
      RMTBrokerSetting.available_securities.find do|p|
        p.plugin_id == securities_id
      end || raise_plugin_not_found(securities_id)
    end
    def self.raise_plugin_not_found(id)
      fail Jiji::Errors::NotFoundException, "plugin is not found. id=#{id}"
    end

  end
end
