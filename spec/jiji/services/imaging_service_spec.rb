# frozen_string_literal: true

require 'jiji/test/test_configuration'
require 'jiji/composing/container_factory'
require 'fileutils'

describe Jiji::Services::ImagingService do
  include_context 'use data_builder'
  let(:base_dir) { data_builder.base_dir }

  after do
    FileUtils.rm_rf './tmp'
  end

  it 'サムネイルを生成できる' do
    service = Jiji::Services::ImagingService.new
    ['01.gif', '01.png', '01.jpg', '02.jpg'].each do |name|
      data = service.create_icon(data_builder.read_image_date(name))
      out(data, name)
    end
  end

  def out(data, name)
    FileUtils.mkdir_p './tmp'
    File.open("./tmp/#{name}", 'w') { |f| f.write(data) }
  end
end
