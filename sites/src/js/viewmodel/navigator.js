import Observable  from "../utils/observable";


const MENU_ITEMS = [
  { route: "/",          text: "ホーム" },
  { route: "/backtests", text: "バックテスト" },
  { route: "/agents",    text: "エージェント" },

  { route: "/settings",  text: "設定" }
];

export default class Navigator extends Observable {

  show() {
    this.fire("request_show");
  }
  menuItems() {
    return MENU_ITEMS;
  }

}
