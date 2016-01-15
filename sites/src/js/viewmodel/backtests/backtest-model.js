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
