import NumberFormatter from "../utils/number-formatter"
import DateFormatter   from "../utils/date-formatter"

export default class NotificationModel {

  constructor(position, urlResolver) {
    for (let i in position) {
      this[i] = position[i];
    }
    this.urlResolver = urlResolver;
  }

  get formatedTimestamp() {
    return DateFormatter.format(this.timestamp);
  }

  get agentIconUrl() {
    const iconId = this.agent ? this.agent.iconId : null;
    return this.urlResolver.resolveServiceUrl(
      "icon-images/" + (iconId || "default"));
  }

  get agentAndBacktestName() {
    let result = "";
    if ( this.agent && this.agent.name != null ) {
      result += this.agent.name;
    }
    result += (result ? " - " : "") +
      (this.backtest.name || "リアルトレード");
    return result;
  }

  get isDisplayChart() {
    return this.options && this.options.chart;
  }
  get chartOption() {
    return (this.options && this.options.chart) || {};
  }
}
