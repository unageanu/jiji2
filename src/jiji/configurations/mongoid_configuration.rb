require 'mongoid'

mongoid_setting_file = "#{File.dirname(__FILE__)}/../../../configurations/mongoid.yml"
Mongoid.load!(mongoid_setting_file, ENV["JIJI_ENV"] || :production)