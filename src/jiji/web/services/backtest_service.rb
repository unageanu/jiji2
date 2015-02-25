# coding: utf-8

require 'sinatra/base'
require 'jiji/web/services/abstract_service'

module Jiji::Web
  class BackTestService < Jiji::Web::AuthenticationRequiredService

    get '/' do
      ok(repository.all)
    end

    get '/:back_test_id' do
      ok(repository.get(param[:back_test_id]))
    end

    delete '/:back_test_id' do
      repository.delete(param[:back_test_id])
      no_content
    end

    def repository
      lookup(:back_test_repository)
    end

  end
end
