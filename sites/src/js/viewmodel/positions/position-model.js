import NumberFormatter from "../utils/number-formatter"
import DateFormatter   from "../utils/date-formatter"

class ClosingPolicyModel {
  constructor(policy) {
    if (policy) for (let i in policy) {
      this[i] = policy[i];
    }
  }
  get formatedTakeProfit() {
    return this.takeProfit ?
      NumberFormatter.insertThousandsSeparator(this.takeProfit) : "-";
  }
  get formatedLossCut() {
    return this.lossCut ?
      NumberFormatter.insertThousandsSeparator(this.lossCut) : "-";
  }
}

export default class PositionModel {

  constructor(position, urlResolver) {
    for (let i in position) {
      if (i === "closingPolicy") {
        this[i] = new ClosingPolicyModel(position[i]);
      } else {
        this[i] = position[i];
      }
    }
    this.urlResolver = urlResolver;
  }

  get formatedProfitOrLoss() {
    return NumberFormatter.insertThousandsSeparator(this.profitOrLoss);
  }
  get formatedSellOrBuy() {
    if (this.sellOrBuy === "sell") {
      return "売";
    } else {
      return "買";
    }
  }
  get formatedUnits() {
    return NumberFormatter.insertThousandsSeparator(this.units);
  }
  get formatedEntryPrice() {
    return NumberFormatter.insertThousandsSeparator(this.entryPrice);
  }
  get formatedExitPrice() {
    return this.exitPrice ?
      NumberFormatter.insertThousandsSeparator(this.exitPrice) : "-";
  }
  get formatedEnteredAt() {
    return DateFormatter.format(this.enteredAt);
  }
  get formatedExitedAt() {
    return this.exitedAt ? DateFormatter.format(this.exitedAt) : "";
  }
  get formatedExitedAtShort() {
    return this.exitedAt
      ? DateFormatter.format(this.exitedAt, "MM-dd hh:mm:ss") : "";
  }
  get agentIconUrl() {
    const iconId = this.agent ? this.agent.iconId : null;
    return this.urlResolver.resolveServiceUrl(
      "icon-images/" + (iconId || "default"));
  }
}
