threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup DefaultRackup
port ENV['PORT']     || 5000
environment ENV['RACK_ENV'] || 'development'

on_restart do
  puts 'On restart...'
end
