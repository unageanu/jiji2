import React        from "react"
import MUI          from "material-ui"
import AbstractPage from "./abstract-page"
import BacktestList from "../backtests/backtest-list"

export default class BacktestsPage extends AbstractPage {
  render() {
    return (
      <div>
        <BacktestList />
      </div>
    );
  }
}
