# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class PositionDownloadService < Jiji::Web::AbstractService

    CSV_COLUMNS = [
      :pair_name, :units, :sell_or_buy, :status, :profit_or_loss,
      :entry_price, :current_price, :exit_price, :entered_at, :exited_at,
      :updated_at, [:agent, :name], [:agent, :agent_class],
      [:agent, :properties], [:backtest, :name]
    ].freeze

    options '/:token' do
      allow('GET,OPTIONS')
    end

    get '/:token' do
      check_and_invalidate_token(params[:token])
      id = read_backtest_id_from(request, 'backtest_id', true)
      sort_order = read_sort_order_from(request, 'order', 'direction', true)
      download_csv('positions.csv', CSV_COLUMNS) do |out|
        repository.retrieve_all_positions(id,
          sort_order, read_filter_condition) do |positions|
            out << positions
          end
      end
    end

    def session_store
      lookup(:session_store)
    end

    def repository
      lookup(:position_repository)
    end

    def check_and_invalidate_token(token)
      unauthorized unless session_store.valid_token?(token, :file_download)
      session_store.invalidate(token)
    end

    def read_filter_condition
      condition = {}
      condition[:status] = request['status'].to_sym if request['status']
      { 'start' => :entered_at.gte, 'end' => :entered_at.lt }.each do |k, v|
        condition[v] = read_time_from(request, k) if request[k]
      end
      condition
    end

  end
end
