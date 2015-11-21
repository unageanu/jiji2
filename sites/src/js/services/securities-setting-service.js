import AbstractService from "./abstract-service"

export default class SecuritiesSettingService extends AbstractService {

  getAvailableSecurities() {
    const url = this.serviceUrl("available-securities");
    return this.xhrManager.xhr( url, "GET");
  }
  getSecuritiesConfiguration(securitiesId) {
    const url = this.serviceUrl("available-securities/"
     + securitiesId + "/configurations");
    return this.xhrManager.xhr( url, "GET");
  }
  getSecuritiesConfigurationDefinitions(securitiesId) {
    const url = this.serviceUrl("available-securities/"
     + securitiesId + "/configuration-definitions");
    return this.xhrManager.xhr( url, "GET");
  }
  getActiveSecuritiesId() {
    const url = this.serviceUrl("active-securities/id");
    return this.xhrManager.xhr( url, "GET");
  }
  setActiveSecurities(securitiesId, configurations) {
    this.googleAnalytics.sendEvent( "set securities", securitiesId );
    const url = this.serviceUrl("active-securities");
    return this.xhrManager.xhr( url, "PUT", {
      "securities_id" : securitiesId,
      configurations: configurations
    });
  }

  endpoint() {
    return "settings/securities";
  }
}
