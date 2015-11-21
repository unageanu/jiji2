import AbstractService from "./abstract-service"

export default class PasswordResettingService extends AbstractService {

  sendPasswordResettingMail(mailAddress) {
    this.googleAnalytics.sendEvent( "send password resetting mail" );
    const url = this.serviceUrl();
    return this.xhrManager.xhr( url, "POST", {
      "mail_address": mailAddress
    });
  }

  resetPassword(token, newPassword) {
    this.googleAnalytics.sendEvent( "reset password" );
    const url = this.serviceUrl();
    return this.xhrManager.xhr( url, "PUT", {
      "token": token,
      "new_password": newPassword
    });
  }

  endpoint() {
    return "settings/password-resetter";
  }
}
