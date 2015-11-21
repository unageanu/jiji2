import AbstractService from "./abstract-service"

export default class SmtpServerSettingService extends AbstractService {

  getStatus() {
    const url = this.serviceUrl("status");
    return this.xhrManager.xhr( url, "GET");
  }
  getSMTPServerSetting() {
    const url = this.serviceUrl();
    return this.xhrManager.xhr( url, "GET");
  }
  setSMTPServerSetting(setting) {
    this.googleAnalytics.sendEvent( "set smtp server" );
    const url = this.serviceUrl();
    return this.xhrManager.xhr( url, "PUT", setting);
  }
  composeTestMail(setting) {
    this.googleAnalytics.sendEvent( "send test mail" );
    const url = this.serviceUrl("test");
    return this.xhrManager.xhr( url, "POST", setting);
  }

  endpoint() {
    return "settings/smtp-server";
  }
}
