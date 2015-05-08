import React      from "react";
import Router     from "react-router";

import Frame        from "./components/frame";
import Home         from "./components/pages/home-page";
import BackTest     from "./components/pages/backtest-page";
import Agents       from "./components/pages/agents-page";
import Settings     from "./components/pages/settings-page";
import Login        from "./components/pages/login-page";

const Route        = Router.Route;
const DefaultRoute = Router.DefaultRoute;

export default (
  <Route handler={Frame} path="/">
    <DefaultRoute           handler={Home} />
    <Route name="backtests" handler={BackTest} />
    <Route name="agents"    handler={Agents} />
    <Route name="settings"  handler={Settings} />
    <Route name="login"     handler={Login} />
  </Route>
);
