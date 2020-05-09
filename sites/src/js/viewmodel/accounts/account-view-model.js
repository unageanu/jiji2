import ContainerJS     from "container-js"
import Observable      from "../../utils/observable"
import NumberFormatter from "../utils/number-formatter"
import DateFormatter   from "../utils/date-formatter"
import _               from "underscore"
import BigDecimal      from "big.js"

export default class AccountViewModel extends Observable {

  constructor(rmtService) {
    super();
    this.rmtService = rmtService;
  }

  initialize() {
    const d = this.rmtService.getAccount();
    d.done((account) => this.setProperties(account));
    return d;
  }

  setProperties(account) {
    _.pairs(account).forEach((pair) => this[pair[0]] = pair[1] );
  }

  calculateChangesFromPreviousDay() {
    if ( this.balance == null || this.balanceOfYesterday == null ) {
      this.setProperty("changesFromPreviousDay", undefined);
      this.setProperty("formattedChangesFromPreviousDay", "-");
      this.setProperty("formattedChangeRatioFromPreviousDay", "-");
    } else {
      const changesFromPreviousDay =
        parseFloat(new BigDecimal(this.balance).minus(this.balanceOfYesterday));
      const changeRatio = changesFromPreviousDay / this.balanceOfYesterday;
      this.setProperty("changesFromPreviousDay", changesFromPreviousDay);
      this.setProperty("formattedChangesFromPreviousDay",
        NumberFormatter.insertThousandsSeparator(changesFromPreviousDay));
      this.setProperty("formattedChangeRatioFromPreviousDay",
        (changesFromPreviousDay > 0 ? "+" : "")
         + NumberFormatter.formatRatio(changeRatio, 2));
    }
  }

  get balance() {
    return this.getProperty("balance");
  }
  set balance(balance) {
    this.setProperty("balance", balance);
    this.setProperty("formattedBalance",
      NumberFormatter.insertThousandsSeparator(balance));
  }
  get profitOrLoss() {
    return this.getProperty("profitOrLoss");
  }
  set profitOrLoss(profitOrLoss) {
    this.setProperty("profitOrLoss", profitOrLoss);
    this.setProperty("formattedProfitOrLoss",
      NumberFormatter.insertThousandsSeparator(profitOrLoss));
  }
  get marginRate() {
    return this.getProperty("marginRate");
  }
  set marginRate(marginRate) {
    this.setProperty("marginRate", marginRate);
    this.setProperty("formattedMarginRate",
      NumberFormatter.formatRatio(marginRate, 2));
  }
  get balanceOfYesterday() {
    return this.getProperty("balanceOfYesterday");
  }
  set balanceOfYesterday(balanceOfYesterday) {
    this.setProperty("balanceOfYesterday", balanceOfYesterday);
    this.calculateChangesFromPreviousDay();
  }

  get changesFromPreviousDay() {
    return this.getProperty("changesFromPreviousDay");
  }
  get formattedChangesFromPreviousDay() {
    return this.getProperty("formattedChangesFromPreviousDay");
  }
  get formattedChangeRatioFromPreviousDay() {
    return this.getProperty("formattedChangeRatioFromPreviousDay");
  }
  get formattedBalance() {
    return this.getProperty("formattedBalance");
  }
  get formattedProfitOrLoss() {
    return this.getProperty("formattedProfitOrLoss");
  }
  get formattedMarginRate() {
    return this.getProperty("formattedMarginRate");
  }

}
