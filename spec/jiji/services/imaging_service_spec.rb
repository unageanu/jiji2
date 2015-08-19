# coding: utf-8

require 'jiji/test/test_configuration'
require 'jiji/composing/container_factory'
require 'fileutils'

describe Jiji::Services::ImagingService do

  after do
    FileUtils.rm_rf "#{base_dir}/tmp"
  end

  it 'サムネイルを生成できる' do
    service = Jiji::Services::ImagingService.new
    ["01.gif", "01.png", "01.jpg", "02.jpg"].each do |name|
      data = service.create_icon(read_image_date(name))
      out(data, name)
    end
  end

  def out(data, name)
    FileUtils.mkdir_p "#{base_dir}/tmp"
    File.open("#{base_dir}/tmp/#{name}", "w").write(data)
  end

  def read_image_date(name)
    File.open("#{base_dir}/#{name}").read
  end

  def base_dir
    File.expand_path("../sample_images", __FILE__)
  end

end
