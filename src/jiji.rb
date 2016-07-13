# coding: utf-8

require 'bundler/setup'
require 'sigdump/setup' if ENV['RACK_ENV'] != 'production'

module Jiji
  module Composing
    module Configurators
      module Infrastructure end
      module Model          end
    end
  end
  module Messaging      end
  module Db             end
  module Errors         end

  module Model
    module Agents       end
    module Graphing     end
    module Logging      end
    module Notification end
    module Settings     end
    module Securities
      module Internal end
    end
    module Trading
      module Brokers          end
      module Internal         end
      module Jobs             end
      module Processes        end
      module Utils            end
      module TradingSummaries end
    end
  end

  module Security end
  module Services
    module AWS          end
  end
  module Utils end
  module Web
    module Transport    end
    module Helpers      end
  end
end

module JIJI
  module Plugin end
end

require 'jiji/web/web_application'
