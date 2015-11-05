# coding: utf-8

require 'figaro'
require 'jiji/utils/requires'

class Application < Figaro::Application

  private

  def default_path
    File.join(Jiji::Utils::Requires.root, 'config', 'application.yml')
  end

  def default_environment
    ENV['RACK_ENV']
  end

end

Figaro.adapter = Application
Figaro.load

ENV['SECRET'] = File.read(ENV['SECRET_FILE_PATH']) if ENV['SECRET_FILE_PATH']

Figaro.require_keys('SECRET')
