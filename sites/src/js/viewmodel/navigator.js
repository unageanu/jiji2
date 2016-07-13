
import Observable  from "../utils/observable"

const MENU_ITEMS = [
  { route: "/",           text: "ホーム",   iconClassName: "md-home" },

  { type:  "header",         text: "リアルトレード" },
  { route: "/rmt/trading-summary", text: "取引状況",         iconClassName: "md-account-balance" },
  { route: "/rmt/chart",           text: "チャート",         iconClassName: "md-trending-up" },
  { route: "/rmt/positions",       text: "建玉一覧",         iconClassName: "md-list" },
  { route: "/rmt/agent-setting",   text: "エージェント設定",  iconClassName: "md-group-add" },
  { route: "/rmt/logs",            text: "ログ",            iconClassName: "md-format-align-left" },

  { type:  "header",         text: "バックテスト" },
  { route: "/backtests/new",       text: "テストの作成", iconClassName: "md-add-circle-outline" },
  { route: "/backtests/list",      text: "テスト一覧",   iconClassName: "md-history" },

  { type:  "header"  },
  { route: "/notifications",       text: "通知一覧",     iconClassName: "md-notifications" },
  { route: "/agents",              text: "エージェント", iconClassName: "md-group" },

  { type:  "header", text: "" },
  { route: "/settings",    text: "設定",              iconClassName: "md-settings" },

  { route: "/login",               text: "ログイン", fullscreen: true, hidden: true },
  { route: "/initial-settings",    text: "初期設定", fullscreen: true, hidden: true },
  { route: "/billing",             text: "ようこそ", fullscreen: true, hidden: true }
];

export default class Navigator extends Observable {

  menuItems() {
    return MENU_ITEMS;
  }

}
