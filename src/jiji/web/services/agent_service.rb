# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class AgentService < Jiji::Web::AuthenticationRequiredService

    options '/sources' do
      allow('GET,POST,OPTIONS')
    end
    get '/sources' do
      sources_without_body = registry.agent_sources.map do |agent|
        hash = agent.to_h
        hash.delete :body
        hash
      end
      ok(sources_without_body)
    end
    post '/sources' do
      body = load_body
      source = registry.add_source(
        body['name'], body['memo'] || '', body['type'], body['body'] || '')
      created(source.to_h)
    end

    options '/sources/:id' do
      allow('GET,PUT,DELETE,OPTIONS')
    end
    get '/sources/:id' do
      ok(registry.find_agent_source_by_id(read_id_from(params)))
    end
    put '/sources/:id' do
      target = registry.find_agent_source_by_id(read_id_from(params))
      body = load_body
      if body.include?('name') && body['name'] != target.name
        registry.rename_source(target.name, body['name'])
      end
      result = registry.update_source(
        body['name'] || target.name, body['memo'] || '', body['body'] || '')
      ok(result)
    end
    delete '/sources/:id' do
      target = registry.find_agent_source_by_id(read_id_from(params))
      registry.remove_source(target.name)
      no_content
    end

    options '/classes' do
      allow('GET,OPTIONS')
    end
    get '/classes' do
      classes = registry.map { |cl| cl }
      ok(classes)
    end

    def registry
      lookup(:agent_registry)
    end

  end
end
