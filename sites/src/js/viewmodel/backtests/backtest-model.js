import NumberFormatter from "../utils/number-formatter"
import DateFormatter   from "../utils/date-formatter"

export default class BacktestModel {

  constructor(backtest) {
    for (let i in backtest) {
      this[i] = backtest[i];
    }
    this.backtest = backtest;
  }

  get formatedPeriod() {
    return DateFormatter.format(this.startTime, "yyyy-MM-dd")
     + " ～ " + DateFormatter.format(this.endTime, "yyyy-MM-dd");
  }

  get formatedBalance() {
    return NumberFormatter.insertThousandsSeparator(this.balance);
  }

  get formatedStatus() {
    const status = this.status;
    switch(status) {
      case "wait_for_finished" :
      case "running" :
        return "実行中";
      case "wait_for_start" :
        return "待機中";
      case "paused" :
      case "cancelled" :
        return "キャンセル";
      case "error" :
        return "エラー";
      case "finished" :
        return "完了";
      default :
        return null;
    }
  }

  get formatedCreatedAt() {
    return DateFormatter.format(this.createdAt, "yyyy-MM-dd hh:mm");
  }

  get tickInterval() {
    const id = this.tickIntervalId;
    switch(id) {
      case "one_minute" :
        return "1分";
      case "fifteen_minutes" :
        return "15分";
      case "thirty_minutes" :
        return "30分";
      case "one_hour" :
        return "1時間";
      case "six_hours" :
        return "6時間";
      case "one_day" :
        return "1日";
      default :
        return "15秒";
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
