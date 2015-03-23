# coding: utf-8

require 'bundler/setup'

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
    module Graph        end
    module Settings     end
    module Trading
      module Brokers    end
      module Internal   end
      module Jobs       end
      module Processes  end
      module Utils      end
    end
  end

  module Plugin         end
  module Security       end
  module Services       end
  module Utils          end
  module Web
    module Transport    end
  end
end

module JIJI
  module Plugin       end
end

require 'jiji/web/web_application'
