import AbstractService from "./abstract-service"

export default class InitialSettingService extends AbstractService {

  isInitialized() {
    return this.xhrManager.xhr( this.serviceUrl("initialized"), "GET" );
  }

  initialize(mailAddress, password) {
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
