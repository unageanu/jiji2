import React                from "react"
import { FormattedMessage } from 'react-intl';

export default class Utils {

  static createStatusContent(backtest) {
    const status = backtest.status;
    switch(status) {
      case "error" :
        return <span className={status}>
          <span className={"icon md-warning"} /> <FormattedMessage id='common.error' />
        </span>;
      default :
        return <span className={status}><FormattedMessage id={`viewmodel.BacktestModel.${backtest.formattedStatus}`} /></span>;
    }
  }

}
