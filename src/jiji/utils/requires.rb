# frozen_string_literal: true

module Jiji::Utils
  class Requires

    def self.root
      File.expand_path('../../..', __dir__)
    end

    def self.require_all(path, base = 'src')
      Dir["#{root}/#{base}/#{path}/**/*.rb"].sort.each do |f|
        require f[(root.length + base.length + 2)..-4]
      end
    end

  end
end
