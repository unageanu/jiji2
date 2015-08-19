# coding: utf-8

require 'mini_magick'

module Jiji::Services
  class ImagingService

    include Jiji::Errors

    def create_icon(stream, w=32, h=32)
      img = MiniMagick::Image.read(stream)
      img.define "size=#{w}x#{h}"
      img.combine_options do |cmd|
        resize_to_fit_longest_edge(cmd, img, w, h)
        cmd.auto_orient
        crop(cmd, img, w, h)
      end
      img.format "png"
      img.to_blob
    end

    private

    def resize_to_fit_longest_edge(cmd, img, w, h)
      cols, rows = img[:dimensions]
      if w != cols || h != rows
        scale = [w/cols.to_f, h/rows.to_f].max
        cols = (scale * (cols + 0.5)).round
        rows = (scale * (rows + 0.5)).round
        cmd.resize "#{cols}x#{rows}"
      end
    end
    def crop(cmd, img, w, h)
      cmd.gravity 'Center'
      cmd.background "rgba(255,255,255,0.0)"
      cmd.extent "#{w}x#{h}"
    end
  end
end
