# coding: utf-8

$:.unshift  File.join(File.dirname(__FILE__), "src")

ENV["RACK_ENV"]="production"

require 'jiji'
run Jiji::Web::WebApplication.instance.build