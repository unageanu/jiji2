# coding: utf-8

require 'mongoid'
require 'jiji/utils/requires'

mongoid_setting_file = "#{Jiji::Utils::Requires.root}/configurations/mongoid.yml"
Mongoid.load!(mongoid_setting_file, ENV["JIJI_ENV"] || :production)