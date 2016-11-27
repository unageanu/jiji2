# coding: utf-8

base = File.dirname(__FILE__)
$LOAD_PATH.unshift File.join(base, 'src')
$LOAD_PATH.unshift File.join(base, 'rpc/ruby')
$LOAD_PATH.unshift File.join(base, 'spec') if ENV['RACK_ENV'] == 'test'

require 'jiji'
require 'newrelic_rpm'
run Jiji::Web::WebApplication.instance.build
