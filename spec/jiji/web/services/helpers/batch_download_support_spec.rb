# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/test/data_builder'
require 'jiji/web/services/helpers/batch_download_support'

describe Jiji::Web::Helpers::BatchDownloadSupport do
  class BatchDownloadSupportMockImplementation

    include Jiji::Web::Helpers::BatchDownloadSupport

    def content_type(*content_type)
      if content_type.empty?
        @content_type
      else
        @content_type = content_type[0]
      end
    end

    def headers(*headers)
      if headers.empty?
        @headers
      else
        @headers = headers[0]
      end
    end

    def stream
      if block_given?
        yield @stream = []
      else
        @stream
      end
    end

  end

  let(:impl) do
    BatchDownloadSupportMockImplementation.new
  end
  let(:data) do
    {
      string1:     'abcあいう',
      string2:     'a,b"c"d',
      string3:     'a"b"c',
      number:      '10',
      big_decimal: BigDecimal.new(10.234, 10) - BigDecimal.new(8.133, 10),
      date:        DateTime.new(2016, 03, 14, 16, 45, 23),
      nil:         nil,
      object:      {
        name:   'abc,"',
        object: { a: 1, b: 2 },
        nil:    nil
      }
    }
  end
  let(:keys) do
    [
      :string1, :string2, :string3, :number, :big_decimal, :date, :nil,
      [:object, :name], [:object, :object], [:object, :nil],
      :unknown, [:unknown, :unknown]
    ]
  end

  describe '#download_csv' do
    it 'can generate a csv data stream.' do
      impl.download_csv('test.csv', keys) do |out|
        out << [data, data, data]
        out << [data, data, data]
        out << [data, data, data]
      end

      expect(impl.content_type).to eq 'text/csv'
      expect(impl.headers).to eq({
        'Content-Disposition' => 'attachment; filename="test.csv"'
      })
      expect(impl.stream.length).to eq 10
      expect(impl.stream[0]).to eq(
        'string1,string2,string3,number,big_decimal,date,nil,' \
        + 'object__name,object__object,object__nil,unknown,unknown__unknown' \
        + "\r\n")
      row = 'abcあいう,"a,b""c""d",a"b"c,10,2.101,' \
              + '"2016-03-14T16:45:23.000+00:00",,' \
              + '"abc,""","{""a"":1,""b"":2}",,,' \
              + "\r\n"
      expect(impl.stream[1]).to eq(row)
      expect(impl.stream[9]).to eq(row)
    end
  end
end
