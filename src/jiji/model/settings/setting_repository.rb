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
        securities:    SecuritiesSetting,
        security:      SecuritySetting,
        rmt:           RMTSetting,
        pair:          PairSetting
      }
    end

    def mail_composer_setting
      load_or_create(:mail_composer)
    end

    def securities_setting
      load_or_create(:securities)
    end

    def security_setting
      load_or_create(:security)
    end

    def rmt_setting
      load_or_create(:rmt)
    end

    def pair_setting
      load_or_create(:pair)
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
