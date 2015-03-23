
module Jiji::Test
end

require 'jiji/test/mock/mock_securities_plugin'

JIJI::Plugin.register(
  JIJI::Plugin::SecuritiesPlugin::FUTURE_NAME,
  Jiji::Test::Mock::MockSecuritiesPlugin.new(:mock))
JIJI::Plugin.register(
  JIJI::Plugin::SecuritiesPlugin::FUTURE_NAME,
  Jiji::Test::Mock::MockSecuritiesPlugin.new(:mock2))
