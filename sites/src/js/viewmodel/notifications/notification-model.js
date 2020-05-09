import NumberFormatter from "../utils/number-formatter"
import DateFormatter   from "../utils/date-formatter"

export default class NotificationModel {

  constructor(position, urlResolver) {
    for (let i in position) {
      this[i] = position[i];
    }
    this.urlResolver = urlResolver;
  }

  get formattedTimestamp() {
    return DateFormatter.format(this.timestamp);
  }

  get agentIconUrl() {
    const iconId = this.agent ? this.agent.iconId : null;
    return this.urlResolver.resolveServiceUrl(
      "icon-images/" + (iconId || "default"));
  }

  getAgentAndBacktestName(formatMessage) {
    let result = "";
    if ( this.agent && this.agent.name != null ) {
      result += this.agent.name;
    }
    result += (result ? " - " : "") +
      (this.backtest.name || formatMessage({ id: 'common.realTrade' }));
    return result;
  }

  get isDisplayChart() {
    return this.options && this.options.chart;
  }
  get chartOption() {
    return (this.options && this.options.chart) || {};
  }
}
