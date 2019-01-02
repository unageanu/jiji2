# frozen_string_literal: true

module Jiji::Web::Helpers
  module BatchDownloadSupport
    include Jiji::Errors

    def download(content_type, filename)
      content_type content_type
      headers({
        'Content-Disposition' => "attachment; filename=\"#{filename}\""
      })
      stream do |out|
        yield out
      end
    end

    def download_csv(filename, columns)
      download('text/csv', filename) do |out|
        yield CSVDownloadStream.new(out, columns)
      end
    end

    class CSVDownloadStream

      def initialize(out, columns)
        @out = out
        @columns = columns
        output_headers
      end

      def <<(rows)
        rows.each do |row|
          @out << format_csv_row(extract_row(row))
        end
      end

      private

      def output_headers
        @out << format_csv_row(@columns.map do |column|
          convert_to_column_name(column)
        end)
      end

      def convert_to_column_name(column)
        if column.is_a?(Array)
          column.map { |k| k.to_s }.join('__')
        else
          column.to_s
        end
      end

      def extract_row(data)
        hash = data.to_h
        @columns.map { |column| extract_value(column, hash) }
      end

      def extract_value(column, hash)
        if column.is_a?(Array)
          column.reduce(hash) { |a, e| a.nil? ? nil : a[e] }
        else
          hash[column]
        end
      end

      def format_csv_row(data)
        data.map { |value| value.to_csv_value }.join(',') + "\r\n"
      end

    end
  end
end
