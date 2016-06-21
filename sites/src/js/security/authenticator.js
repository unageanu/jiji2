import Deferred    from "../utils/deferred"
import ContainerJS from "container-js"
import Error       from "../model/error"

export default class Authenticator {

  constructor() {
    this.sessionManager = ContainerJS.Inject;
    this.xhrManager     = ContainerJS.Inject;
    this.urlResolver    = ContainerJS.Inject;
  }

  login(password) {
    var d = new Deferred();
    const serviceUrl = this.urlResolver.resolveServiceUrl("authenticator");
    this.xhrManager.xhr(
      serviceUrl, "POST", {password:password}
    ).then((result) => {
      this.sessionManager.setToken(result.token);
      d.resolve(result.token);
    }, (error) => {
      d.reject(error);
    });
    return d;
  }

  logout() {
    var d = new Deferred();
    const token = this.sessionManager.getToken();
    const serviceUrl = this.urlResolver.resolveServiceUrl("sessions");
    if (token) {
      this.xhrManager.xhr(
        serviceUrl, "DELETE", {token: token}
      ).both((result) => {
        this.sessionManager.deleteToken();
        d.resolve();
      });
    } else {
      d.resolve();
    }
    return d;
  }

}
