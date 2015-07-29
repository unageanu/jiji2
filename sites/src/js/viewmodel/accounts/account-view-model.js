import ContainerJS     from "container-js"
import Observable      from "../../utils/observable"
import NumberFormatter from "../utils/number-formatter"
import DateFormatter   from "../utils/date-formatter"
import _               from "underscore"

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

  get balance() {
    return this.getProperty("balance");
  }
  set balance(balance) {
    this.setProperty("balance", balance);
    this.setProperty("formatedBalance",
      NumberFormatter.insertThousandsSeparator(balance));
  }
  get profitOrLoss() {
    return this.getProperty("profitOrLoss");
  }
  set profitOrLoss(profitOrLoss) {
    this.setProperty("profitOrLoss", profitOrLoss);
    this.setProperty("formatedProfitOrLoss",
      NumberFormatter.insertThousandsSeparator(profitOrLoss));
  }
  get marginRate() {
    return this.getProperty("marginRate");
  }
  set marginRate(marginRate) {
    this.setProperty("marginRate", marginRate);
    this.setProperty("formatedMarginRate",
      NumberFormatter.formatRatio(marginRate, 2));
  }

  get formatedBalance() {
    return this.getProperty("formatedBalance");
  }
  get formatedProfitOrLoss() {
    return this.getProperty("formatedProfitOrLoss");
  }
  get formatedMarginRate() {
    return this.getProperty("formatedMarginRate");
  }

}
