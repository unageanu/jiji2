import NumberFormatter from "../utils/number-formatter"
import DateFormatter   from "../utils/date-formatter"

class ClosingPolicyModel {
  constructor(policy) {
    if (policy) for (let i in policy) {
      this[i] = policy[i];
    }
  }
  get formattedTakeProfit() {
    return this.takeProfit ?
      NumberFormatter.insertThousandsSeparator(this.takeProfit) : "-";
  }
  get formattedLossCut() {
    return this.stopLoss ?
      NumberFormatter.insertThousandsSeparator(this.stopLoss) : "-";
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

  get formattedProfitOrLoss() {
    return NumberFormatter.insertThousandsSeparator(this.profitOrLoss);
  }
  get formattedSellOrBuy() {
    if (this.sellOrBuy === "sell") {
      return "common.sell";
    } else {
      return "common.buy";
    }
  }
  get formattedStatus() {
    if (this.status === "live") {
      return "viewmodel.PositionModel.status.live";
    } else if (this.status === "closed"){
      return "viewmodel.PositionModel.status.closed";
    } else if (this.status === "lost"){
      return "viewmodel.PositionModel.status.lost";
    }
  }
  get formattedUnits() {
    return NumberFormatter.insertThousandsSeparator(this.units);
  }
  get formattedEntryPrice() {
    return NumberFormatter.insertThousandsSeparator(this.entryPrice);
  }
  get formattedExitPrice() {
    return this.exitPrice ?
      NumberFormatter.insertThousandsSeparator(this.exitPrice) : "-";
  }
  get formattedEnteredAt() {
    return DateFormatter.format(this.enteredAt);
  }
  get formattedExitedAt() {
    return this.exitedAt ? DateFormatter.format(this.exitedAt) : "";
  }
  get formattedExitedAtShort() {
    return this.exitedAt
      ? DateFormatter.format(this.exitedAt, "MM-dd hh:mm:ss") : "";
  }
  get agentIconUrl() {
    const iconId = this.agent ? this.agent.iconId : null;
    return this.urlResolver.resolveServiceUrl(
      "icon-images/" + (iconId || "default"));
  }
  get agentName() {
    return this.agent ? this.agent.name : null;
  }
}
