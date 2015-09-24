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
}
