import MUI         from "material-ui";
import Observable  from "../utils/observable";

const Types = MUI.MenuItem.Types;

const MENU_ITEMS = [
  { route: "/",           text: "ホーム",   iconClassName: "md-home" },

  { type: Types.SUBHEADER,       text: "リアルトレード" },
  { route: "/rmt-status",        text: "取引状況",         iconClassName: "md-account-balance" },
  { route: "/rmt-chart",         text: "チャート",         iconClassName: "md-trending-up" },
  { route: "/rmt-positions",     text: "建玉一覧",         iconClassName: "md-list" },
  { route: "/rmt-agent-setting", text: "エージェント設定",  iconClassName: "md-group-add" },

  { type: Types.SUBHEADER  },
  { route: "/notifications",    text: "通知一覧",     iconClassName: "md-notifications" },
  { route: "/agents",           text: "エージェント", iconClassName: "md-group" },
  { route: "/backtests",        text: "バックテスト", iconClassName: "md-history" },

  { type: Types.SUBHEADER, text: "" },
  { route: "/settings",    text: "設定",              iconClassName: "md-settings" },
  { route: "/login",       text: "ログイン" }
];

export default class Navigator extends Observable {

  show() {
    this.fire("request_show");
  }
  menuItems() {
    return MENU_ITEMS;
  }

}
