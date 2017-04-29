# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Rpc::Services::LoggingService do
  describe 'resolve_log_level' do
    it 'resolve log_level from string' do
      Severity = Logger::Severity
      service = Jiji::Rpc::Services::LoggingService.new
      expect(service.resolve_log_level('WARN')).to eq Severity::WARN
      expect(service.resolve_log_level('ERROR')).to eq Severity::ERROR
      expect(service.resolve_log_level('INFO')).to eq Severity::INFO
      expect(service.resolve_log_level('DEBUG')).to eq Severity::DEBUG
      expect(service.resolve_log_level('FATAL')).to eq Severity::FATAL
      expect(service.resolve_log_level('UNKNOWN')).to eq Severity::UNKNOWN
      expect(service.resolve_log_level('')).to eq Severity::UNKNOWN
      expect(service.resolve_log_level(nil)).to eq Severity::UNKNOWN
    end
  end
end
