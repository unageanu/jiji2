import React               from "react"
import MUI                 from "material-ui"

export default class Utils {

  static createStatusContent(backtest) {
    const status = backtest.status;
    switch(status) {
      case "error" :
        return <span className={status}>
          <span className={"icon md-warning"} /> エラー
        </span>;
      default :
        return <span className={status}>{backtest.formatedStatus}</span>;
    }
  }

}
