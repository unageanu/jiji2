# coding: utf-8

module Jiji::Model::Graphing::Internal
  module AggregationStrategies
    def self.create(aggregation_type)
      case aggregation_type
      when :average then Average.new
      when :first   then First.new
      when :last    then Last.new
      else fail ArgumentError,
        "unknown aggregation_type. type=#{aggregation_type}"
      end
    end

    class AbstractStrategy

      def initialize
        @contexts = []
      end

      def merge(values)
        values.each_with_index do |item, index|
          context = @contexts[index] || (@contexts[index] = initial_context)
          update_context(item, context) unless item.nil?
        end
      end

      def calculate
        @contexts.map do |context|
          calculate_value(context)
        end
      end

    end

    class Average < AbstractStrategy

      def initial_context
        { count: 0, sum: BigDecimal.new(0, 10) }
      end

      def update_context(value, context)
        context[:sum]   += value
        context[:count] += 1
      end

      def calculate_value(context)
        return 0 unless context && context[:count] > 0
        (context[:sum] / context[:count]).to_f
      end

    end

    class First < AbstractStrategy

      def initial_context
        { v: nil }
      end

      def update_context(value, context)
        context[:v] = value if context[:v].nil?
      end

      def calculate_value(context)
        context[:v]
      end

    end

    class Last < AbstractStrategy

      def initial_context
        { v: nil }
      end

      def update_context(value, context)
        context[:v] = value
      end

      def calculate_value(context)
        context[:v]
      end

    end
  end
end
