import React      from "react";
import Router     from "react-router";

import Frame        from "./components/frame";
import Home         from "./components/pages/home-page";
import BackTests    from "./components/pages/backtests-page";
import NewBackTest  from "./components/pages/new-backtest-page";
import Agents       from "./components/pages/agents-page";
import Settings     from "./components/pages/settings-page";
import Login        from "./components/pages/login-page";

const Route        = Router.Route;
const DefaultRoute = Router.DefaultRoute;

export default (
  <Route handler={Frame} path="/">
    <DefaultRoute                handler={Home} />
    <Route path="backtests/new"  handler={NewBackTest} />
    <Route path="backtests/list" handler={BackTests}>
      <Route path=":id" handler={BackTests} ignoreScrollBehavior={true}>
      </Route>
    </Route>
    <Route path="agents"         handler={Agents} />
    <Route path="settings"       handler={Settings} />
    <Route path="login"          handler={Login} />
  </Route>
);
