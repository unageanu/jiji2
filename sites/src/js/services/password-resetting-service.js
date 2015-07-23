import AbstractService from "./abstract-service"

export default class PasswordResettingService extends AbstractService {

  sendPasswordResettingMail(mailAddress) {
    const url = this.serviceUrl();
    return this.xhrManager.xhr( url, "POST", {
      "mail_address": mailAddress
    });
  }

  resetPassword(token, newPassword) {
    const url = this.serviceUrl();
    return this.xhrManager.xhr( url, "PUT", {
      "token": mailAddress,
      "new_password": newPassword
    });
  }

  endpoint() {
    return "settings/password-resetter";
  }
}
