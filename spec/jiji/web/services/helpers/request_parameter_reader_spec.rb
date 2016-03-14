# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'
require 'jiji/web/services/helpers/request_parameter_reader'

describe Jiji::Web::Helpers::RequestParameterReader do
  let(:reader) do
    Class.new.include(Jiji::Web::Helpers::RequestParameterReader).new
  end
  let(:object_id) { BSON::ObjectId.from_string('56dd6836e138234d25f0c318') }
  let(:source) do
    {
      'number'       => '10',
      'id'           => object_id.to_s,
      'backtest_id1' => object_id.to_s,
      'backtest_id2' => 'rmt',
      'time'         => '2016-02-07T02:28:50.225Z',
      'order'        => 'order',
      'asc'          => 'asc',
      'desc'         => 'desc'
    }
  end

  describe '#read_integer_from' do
    using RSpec::Parameterized::TableSyntax

    where(:key, :nullable, :result) do
      'number'  | false | 10
      'unknown' | false | ArgumentError
      'number'  | true  | 10
      'unknown' | true  | nil
    end

    with_them do
      if params[:result].is_a?(Class) && Exception > params[:result]
        it "raises #{params[:result]}" do
          expect do
            reader.read_integer_from(source, key, nullable)
          end.to raise_exception(result)
        end
      else
        it "returns #{params[:result]}" do
          expect(reader.read_integer_from(source, key, nullable)).to eq result
        end
      end
    end
  end

  describe '#read_id_from' do
    using RSpec::Parameterized::TableSyntax

    where(:key, :nullable, :result) do
      'id'      | false | object_id
      'unknown' | false | ArgumentError
      'id'      | true  | object_id
      'unknown' | true  | nil
    end

    with_them do
      if params[:result].is_a?(Class) && Exception > params[:result]
        it "raises #{params[:result]}" do
          expect do
            reader.read_id_from(source, key, nullable)
          end.to raise_exception(result)
        end
      else
        it "returns #{params[:result]}" do
          expect(reader.read_id_from(source, key, nullable)).to eq result
        end
      end
    end
  end

  describe '#read_backtest_id_from' do
    using RSpec::Parameterized::TableSyntax

    where(:key, :nullable, :result) do
      'backtest_id1' | false | object_id
      'backtest_id2' | false | nil
      'unknown'      | false | ArgumentError
      'backtest_id1' | true  | object_id
      'backtest_id2' | true  | nil
      'unknown'      | true  | nil
    end

    with_them do
      if params[:result].is_a?(Class) && Exception > params[:result]
        it "raises #{params[:result]}" do
          expect do
            reader.read_backtest_id_from(source, key, nullable)
          end.to raise_exception(result)
        end
      else
        it "returns #{params[:result]}" do
          expect(
            reader.read_backtest_id_from(source, key, nullable)
          ).to eq result
        end
      end
    end
  end

  describe '#read_time_from' do
    using RSpec::Parameterized::TableSyntax

    where(:key, :nullable, :result) do
      'time'    | false | Time.parse('2016-02-07T02:28:50.225Z')
      'unknown' | false | ArgumentError
      'time'    | true  | Time.parse('2016-02-07T02:28:50.225Z')
      'unknown' | true  | nil
    end

    with_them do
      if params[:result].is_a?(Class) && Exception > params[:result]
        it "raises #{params[:result]}" do
          expect do
            reader.read_time_from(source, key, nullable)
          end.to raise_exception(result)
        end
      else
        it "returns #{params[:result]}" do
          expect(
            reader.read_time_from(source, key, nullable)
          ).to eq result
        end
      end
    end
  end

  describe '#read_sort_order_from' do
    using RSpec::Parameterized::TableSyntax

    where(:key, :direction_key, :nullable, :result) do
      'order'   | 'asc'     | false | { order: :asc }
      'order'   | 'unknown' | false | { order: :asc }
      'unknown' | 'asc'     | false | ArgumentError
      'order'   | 'desc'    | true  | { order: :desc }
      'unknown' | 'unknown' | true  | nil
    end

    with_them do
      if params[:result].is_a?(Class) && Exception > params[:result]
        it "raises #{params[:result]}" do
          expect do
            reader.read_sort_order_from(source, key, direction_key, nullable)
          end.to raise_exception(result)
        end
      else
        it "returns #{params[:result]}" do
          expect(
            reader.read_sort_order_from(source, key, direction_key, nullable)
          ).to eq result
        end
      end
    end
  end
end
