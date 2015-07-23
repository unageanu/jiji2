import AbstractService from "./abstract-service"

export default class SecuritiesSettingService extends AbstractService {

  getAvailableSecurities() {
    const url = this.serviceUrl("available-securities");
    return this.xhrManager.xhr( url, "GET");
  }
  getSecuritiesConfiguration(securitiesId) {
    const url = this.serviceUrl("available-securities/"
     + securitiesId + "/configuration_definitions");
    return this.xhrManager.xhr( url, "GET");
  }
  getActiveSecuritiesId() {
    const url = this.serviceUrl("active-securities/id");
    return this.xhrManager.xhr( url, "GET");
  }
  setActiveSecurities(securitiesId, configurations) {
    const url = this.serviceUrl("active-securities");
    return this.xhrManager.xhr( url, "PUT", {
      securities_id : securitiesId,
      configurations: configurations
    });
  }

  endpoint() {
    return "settings/securities";
  }
}
