require 'simplecov'
require 'codeclimate-test-reporter'

if ENV['ENABLE_COVERADGE_REPORT'] != 'false'
  dir = File.join(BUILD_DIR, 'coverage')
  SimpleCov.coverage_dir(dir)
  SimpleCov.start do
    add_filter '/vendor/'
    add_filter '/src/jiji/web/'
    add_filter '/spec/'
    add_filter '/rest_spec/'
    formatter SimpleCov::Formatter::MultiFormatter.new([
      SimpleCov::Formatter::HTMLFormatter,
      CodeClimate::TestReporter::Formatter
    ])
  end
end
