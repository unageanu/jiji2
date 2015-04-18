import React      from "react";
import Router     from "react-router";

import MainView     from "./components/main-view";
import Home         from "./components/home-view";
import BackTest     from "./components/backtest-view";
import Agents       from "./components/agents-view";
import Settings     from "./components/settings-view";

const Route        = Router.Route;
const DefaultRoute = Router.DefaultRoute;

export default (
  <Route handler={MainView} path="/">
    <DefaultRoute           handler={Home} />
    <Route name="backtests" handler={BackTest} />
    <Route name="agents"    handler={Agents} />
    <Route name="settings"  handler={Settings} />
  </Route>
);
