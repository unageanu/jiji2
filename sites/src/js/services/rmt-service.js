import AbstractService from "./abstract-service"

export default class RmtService extends AbstractService {

  getAgentSetting() {
    return this.xhrManager.xhr(this.serviceUrl( "agents" ), "GET");
  }
  putAgentSetting(settings) {
    return this.xhrManager.xhr(
      this.serviceUrl("agents"), "PUT", settings);
  }

  endpoint() {
    return "rmt";
  }
}
