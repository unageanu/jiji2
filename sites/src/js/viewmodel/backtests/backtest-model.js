import NumberFormatter from "../utils/number-formatter"
import DateFormatter   from "../utils/date-formatter"

export default class BacktestModel {

  constructor(backtest) {
    for (let i in backtest) {
      this[i] = backtest[i];
    }
    this.backtest = backtest;
  }

  get formattedPeriod() {
    return DateFormatter.format(this.startTime, "yyyy-MM-dd")
     + " ～ " + DateFormatter.format(this.endTime, "yyyy-MM-dd");
  }

  get formattedBalance() {
    return NumberFormatter.insertThousandsSeparator(this.balance);
  }

  get formattedStatus() {
    const status = this.status;
    switch(status) {
      case "wait_for_finished" :
      case "running" :
        return "running";
      case "wait_for_start" :
        return "waitForStart";
      case "paused" :
      case "cancelled" :
        return "cancelled";
      case "error" :
        return "error";
      case "finished" :
        return "finished";
      default :
        return null;
    }
  }

  get formattedCreatedAt() {
    return DateFormatter.format(this.createdAt, "yyyy-MM-dd hh:mm");
  }

  get tickInterval() {
    const id = this.tickIntervalId;
    switch(id) {
      case "one_minute" :
        return "oneMinute";
      case "fifteen_minutes" :
        return "fifteenMinutes";
      case "thirty_minutes" :
        return "thirtyMinutes";
      case "one_hour" :
        return "oneHour";
      case "six_hours" :
        return "sixHours";
      case "one_day" :
        return "oneDay";
      default :
        return "fifteenSeconds";
    }
  }

  get enableDelete() {
    return this.backtest.isFinished();
  }
  get enableRestart() {
    return this.backtest.isFinished();
  }
  get enableCancel() {
    return !this.backtest.isFinished();
  }

}
