# coding: utf-8

require 'encase'

module Jiji::Model::Settings
  class SettingRepository < AbstractSetting

    include Encase

    attr_accessor :container

    def initialize
      super
      @categories = {
        mail_composer: MailComposerSetting,
        rmt_broker:    RMTBrokerSetting,
        security:      SecuritySetting
      }
    end

    def mail_composer_setting
      load_or_create(:mail_composer)
    end

    def rmt_broker_setting
      load_or_create(:rmt_broker)
    end

    def security_setting
      load_or_create(:security)
    end

    private

    def load_or_create(category)
      setting = find(category) || resolve_class(category).new
      container.inject(setting)
      setting
    end

    def find(category)
      AbstractSetting.find_by(category: category)
    end

    def resolve_class(category)
      @categories[category] \
      || illegal_argument('unknown category.', category: category)
    end

  end
end
