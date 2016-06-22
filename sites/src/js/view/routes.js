import React      from "react"
import { Router, Route, IndexRoute } from 'react-router'

import Frame             from "./components/frame"
import Home              from "./components/pages/home-page"
import BackTests         from "./components/pages/backtests-page"
import NewBackTest       from "./components/pages/new-backtest-page"
import RMTChart          from "./components/pages/rmt-chart-page"
import RMTTradingSummary from "./components/pages/rmt-trading-summary-page"
import RMTPositions      from "./components/pages/rmt-positions-page"
import RMTAgentSetting   from "./components/pages/rmt-agent-setting-page"
import RMTLogs           from "./components/pages/rmt-log-page"
import Notifications     from "./components/pages/notifications-page"
import Agents            from "./components/pages/agents-page"
import Settings          from "./components/pages/settings-page"
import InitialSettings   from "./components/pages/initial-settings-page"
import Login             from "./components/pages/login-page"

export default (
  <Route component={Frame} path="/">
    <IndexRoute                        component={Home} />
    <Route path="rmt/trading-summary"  component={RMTTradingSummary} />
    <Route path="rmt/chart"            component={RMTChart} />
    <Route path="rmt/positions"        component={RMTPositions}>
      <Route path=":id" component={RMTPositions} ignoreScrollBehavior={true}>
      </Route>
    </Route>
    <Route path="rmt/agent-setting"    component={RMTAgentSetting} />
    <Route path="rmt/logs"             component={RMTLogs} />

    <Route path="backtests/new"        component={NewBackTest} />
    <Route path="backtests/list"       component={BackTests}>
      <Route path=":id" component={BackTests} ignoreScrollBehavior={true}>
      </Route>
    </Route>

    <Route path="notifications"        component={Notifications}>
      <Route path=":id" component={Notifications} ignoreScrollBehavior={true}>
      </Route>
    </Route>
    <Route path="agents"               component={Agents} />
    <Route path="settings"             component={Settings} />

    <Route path="initial-settings"     component={InitialSettings} />
    <Route path="login"                component={Login} />
  </Route>
);
