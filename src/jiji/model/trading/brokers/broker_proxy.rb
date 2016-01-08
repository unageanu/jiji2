# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'forwardable'

module Jiji::Model::Trading::Brokers
  class BrokerProxy

    extend Forwardable

    def_delegators :@broker, :pairs, :tick, :positions, :orders, :account,
      :modify_order, :cancel_order, :modify_position, :close_position,
      :refresh, :refresh_positions, :refresh_account

    attr_reader :agent #:nodoc:

    def initialize(broker, agent) #:nodoc:
      @broker  = broker
      @agent   = agent
    end

    # 買い注文を行います
    #
    # pair_name:: 通貨ペア名
    # units:: 注文単位
    # type:: 取引の種別。成行 (:market)、指値 (:limit)、逆指値 (stop)、
    #        Market If Touched (:marketIfTouched) のいずれかが指定可能です。
    # options:: 指値注文の指値価格や、有効期限などを指定します。
    # 戻り値:: OrderResult
    def buy(pair_name, units, type = :market, options = {})
      @broker.buy(pair_name, units, type, options, @agent)
    end

    # 売り注文を行います
    #
    # pair_name:: 通貨ペア名
    # units:: 注文単位
    # type:: 取引の種別。成行 (:market)、指値 (:limit)、逆指値 (stop)、
    #        Market If Touched (:marketIfTouched) のいずれかが指定可能です。
    # options:: 指値注文の指値価格や、有効期限などを指定します。
    # 戻り値:: OrderResult
    def sell(pair_name, units, type = :market, options = {})
      @broker.sell(pair_name, units, type, options, @agent)
    end

  end
end
