# coding: utf-8

require 'set'

module Jiji::Model::Trading::Utils
  class Same

    def match(available_pairs, steps)
      steps[0] == steps[1]
    end

    def resolve_rate(tick, steps)
      1
    end

    def resolve_required_pairs(available_pairs, steps)
      []
    end

  end

  class IncludedInTick

    def match(available_pairs, steps)
      available_pairs.include?((steps[0] + steps[1]).to_sym)
    end

    def resolve_rate(tick, steps)
      tick[(steps[0] + steps[1]).to_sym].mid
    end

    def resolve_required_pairs(available_pairs, steps)
      [(steps[0] + steps[1]).to_sym]
    end

  end

  class NotIncludedInTick

    def match(available_pairs, steps)
      true
    end

    def resolve_rate(tick, steps)
      pairs = resolve_required_pairs(tick, steps)
      (BigDecimal.new(tick[pairs[0]].mid, 10) \
           / BigDecimal.new(tick[pairs[1]].mid, 10)).round(6)
    end

    def resolve_required_pairs(available_pairs, steps)
      %w(USD EUR).each do |candidate|
        a = (candidate + steps[1]).to_sym
        b = (candidate + steps[0]).to_sym
        next unless available_pairs.include?(a) && available_pairs.include?(b)
        return [a, b]
      end
      raise "counter pair is not found. pair=#{steps.join}"
    end

  end

  class CounterPairResolver

    STRATEGIES = [
      Same.new,
      IncludedInTick.new,
      NotIncludedInTick.new
    ].freeze

    def resolve_rate(tick, pair_name, account_currency)
      steps = resolve_counter_pairs(pair_name, account_currency)
      find_strategy(tick, steps).resolve_rate(tick, steps)
    end

    def resolve_pair(pair_name, account_currency)
      steps = resolve_counter_pairs(pair_name, account_currency)
      steps.join.to_sym
    end

    def resolve_required_pairs(pairs, pair_name, account_currency)
      available_pairs = convert_to_set(pairs)
      steps = resolve_counter_pairs(pair_name, account_currency)
      find_strategy(available_pairs, steps)
        .resolve_required_pairs(available_pairs, steps)
    end

    private

    def find_strategy(available_pairs, steps)
      STRATEGIES.find { |s| s.match(available_pairs, steps) }
    end

    def resolve_counter_pairs(pair_name, account_currency)
      [pair_name.to_s[3..6], account_currency]
    end

    def convert_to_set(pairs)
      pairs.all.each_with_object(Set.new) do |p, s|
        s << p.name
      end
    end

  end
end
