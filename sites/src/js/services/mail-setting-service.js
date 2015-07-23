import AbstractService from "./abstract-service"

export default class UserSettingService extends AbstractService {

  getMailAddress(mailAddress) {
    const url = this.serviceUrl("mailaddress");
    return this.xhrManager.xhr( url, "GET");
  }

  setMailAddress(mailAddress) {
    const url = this.serviceUrl("mailaddress");
    return this.xhrManager.xhr( url, "PUT", {
      "mail_address": mailAddress
    });
  }

  setPassword(old, new) {
    const url = this.serviceUrl("password");
    return this.xhrManager.xhr( url, "PUT", {
      "old_password": old,
      "password":     new
    });
  }

  endpoint() {
    return "settings/user";
  }
}
