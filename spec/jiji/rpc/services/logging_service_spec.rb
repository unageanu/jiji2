# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Rpc::Services::LoggingService do
  describe 'resolve_log_level' do
    it 'resolve log_level from string' do
      service = Jiji::Rpc::Services::LoggingService.new
      expect(service.resolve_log_level("WARN")).to eq Logger::Severity::WARN
      expect(service.resolve_log_level("ERROR")).to eq Logger::Severity::ERROR
      expect(service.resolve_log_level("INFO")).to eq Logger::Severity::INFO
      expect(service.resolve_log_level("DEBUG")).to eq Logger::Severity::DEBUG
      expect(service.resolve_log_level("FATAL")).to eq Logger::Severity::FATAL
      expect(service.resolve_log_level("UNKNOWN")).to eq Logger::Severity::UNKNOWN
      expect(service.resolve_log_level("")).to eq Logger::Severity::UNKNOWN
      expect(service.resolve_log_level(nil)).to eq Logger::Severity::UNKNOWN
    end
  end
end
