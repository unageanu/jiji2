
module Jiji::Utils
  class Collections

    def self.to_map(items, &block)
      items.each_with_object({}) do |item, r|
        r[block.call(item)] = item
      end
    end

  end
end
