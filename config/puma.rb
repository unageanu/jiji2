# frozen_string_literal: true

threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup DefaultRackup
port ENV['PORT'] || 5000
environment ENV['RACK_ENV'] || 'production'

daemonize ENV['PUMA_DAEMONIZE'] == 'true' || false

app_path = ENV['PUMA_APPLICATION_PATH']
directory app_path if !app_path.nil? && !app_path.empty?
