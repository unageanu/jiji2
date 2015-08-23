# coding: utf-8

require 'mini_magick'

module Jiji::Services
  class ImagingService

    include Jiji::Errors

    def create_icon(stream, w = 40, h = 40)
      img = MiniMagick::Image.read(stream)
      img.define "size=#{w}x#{h}"
      img.combine_options do |cmd|
        resize_to_fit_longest_edge(cmd, img, w, h)
        cmd.auto_orient
        crop(cmd, img, w, h)
      end
      img.format 'png'
      img.to_blob
    end

    private

    def resize_to_fit_longest_edge(cmd, img, w, h)
      cols, rows = img[:dimensions]
      return if w == cols && h == rows
      scale = calculate_scale(w, h, cols, rows)
      cmd.resize "#{(cols * scale).ceil}x#{(rows * scale).ceil}"
    end

    def calculate_scale(w, h, cols, rows)
      [w / cols.to_f, h / rows.to_f].max
    end

    def crop(cmd, img, w, h)
      cmd.gravity 'Center'
      cmd.background 'rgba(255,255,255,0.0)'
      cmd.extent "#{w}x#{h}"
    end

  end
end
