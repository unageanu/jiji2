# coding: utf-8

require 'jiji/configurations/mongoid_configuration'
require 'jiji/utils/value_object'
require 'jiji/errors/errors'
require 'jiji/web/transport/transportable'

module Jiji::Model::Agents
  class AgentSource

    include Mongoid::Document
    include Jiji::Utils::ValueObject
    include Jiji::Web::Transport::Transportable
    include Jiji::Errors

    store_in collection: 'agent_sources'

    field :name,          type: String
    field :memo,          type: String
    field :type,          type: Symbol
    field :status,        type: Symbol
    field :body,          type: String

    field :created_at,    type: Time
    field :updated_at,    type: Time

    validates :name,
      length:   { maximum: 200, strict: true },
      presence: { strict: true }

    validates :memo,
      length:      { maximum: 2000, strict: true },
      allow_nil:   true,
      allow_blank: true

    validates :created_at,
      presence: { strict: true }
    validates :updated_at,
      presence: { strict: true }

    attr_readonly :type, :created_at
    attr_reader :error, :context

    index(
      { updated_at: 1, id: 1 },
      unique: true, name: 'agent_sources_updated_at_id_index')
    index(
      { type: 1, name: 1, id: 1 },
      unique: true, name: 'agent_sources_type_name_id_index')

    def self.create(name, type, created_at, memo = '', body = '')
      source = AgentSource.new do |a|
        a.name       = name
        a.type       = type
        a.created_at = created_at
        a.updated_at = created_at
        a.memo       = memo
        a.body       = body
      end
      source.evaluate_and_save
      source
    end

    def evaluate_and_save
      evaluate
      save
    end

    def update(name = nil, updated_at = nil, memo = nil, body = nil)
      self.name       = name       || self.name
      self.memo       = memo       || self.memo
      self.body       = body       || self.body
      self.updated_at = updated_at || self.updated_at
      evaluate_and_save
    end

    def evaluate
      return change_state_to_empty if body.nil? || body.empty?
      @context = Context.new_context
      begin
        @context.module_eval(body, "#{type}/#{name}", 1)
        change_state_to_normal
      rescue Exception => e # rubocop:disable Lint/RescueException
        change_state_to_error(e)
      end
      @context
    end

    def to_h
      hash = {}
      insert_file_information_to_hash(hash)
      insert_status_and_error_information_to_hash(hash)
      hash
    end

    private

    def insert_file_information_to_hash(hash)
      hash[:id]         = _id
      hash[:name]       = name
      hash[:memo]       = memo
      hash[:type]       = type
      hash[:body]       = body
      hash[:created_at] = created_at
      hash[:updated_at] = updated_at
    end

    def insert_status_and_error_information_to_hash(hash)
      hash[:status] = status
      hash[:error]  = @error
    end

    def change_state_to_normal
      @error = nil
      self.status = :normal
    end

    def change_state_to_empty
      @error = nil
      self.status = :empty
    end

    def change_state_to_error(error)
      @error = error.to_s
      self.status = :error
    end

  end
end
