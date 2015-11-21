import AbstractService from "./abstract-service"

export default class InitialSettingService extends AbstractService {

  isInitialized() {
    return this.xhrManager.xhr( this.serviceUrl("initialized"), "GET", {}, {
      timeout: 1000 * 10
    });
  }

  initialize(mailAddress, password) {
    this.googleAnalytics.sendEvent( "initialize" );
    const url = this.serviceUrl("mailaddress-and-password");
    return this.xhrManager.xhr( url, "PUT", {
      "mail_address": mailAddress,
      "password":     password
    });
  }

  endpoint() {
    return "settings/initialization";
  }
}
