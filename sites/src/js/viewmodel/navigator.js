
import Observable  from "../utils/observable"

const MENU_ITEMS = [
  { route: "/",                    labelId: "home",           iconClassName: "md-home" },

  { type:  "header",               labelId: "realtrade" },
  { route: "/rmt/trading-summary", labelId: "tradingSummary", iconClassName: "md-account-balance" },
  { route: "/rmt/chart",           labelId: "chart",          iconClassName: "md-trending-up" },
  { route: "/rmt/positions",       labelId: "positions",      iconClassName: "md-list" },
  { route: "/rmt/agent-setting",   labelId: "agentSetting",   iconClassName: "md-group-add" },
  { route: "/rmt/logs",            labelId: "logs",           iconClassName: "md-format-align-left" },

  { type:  "header",               labelId: "backtest" },
  { route: "/backtests/new",       labelId: "newBackTest",    iconClassName: "md-add-circle-outline" },
  { route: "/backtests/list",      labelId: "backtestList",   iconClassName: "md-history" },

  { type:  "header" },
  { route: "/notifications",       labelId: "notifications",  iconClassName: "md-notifications" },
  { route: "/agents",              labelId: "agents",         iconClassName: "md-group" },

  { type:  "header" },
  { route: "/settings",            labelId: "settings",       iconClassName: "md-settings" },

  { route: "/login",               labelId: "login",           fullscreen: true, hidden: true },
  { route: "/initial-settings",    labelId: "initialSettings", fullscreen: true, hidden: true },
  { route: "/billing",             labelId: "welcome",         fullscreen: true, hidden: true }
];

export default class Navigator extends Observable {

  menuItems() {
    return MENU_ITEMS;
  }

}
