# coding: utf-8

$:.unshift  File.join(File.dirname(__FILE__), "src")

require 'jiji'
run Jiji::Web::WebApplication.new.build