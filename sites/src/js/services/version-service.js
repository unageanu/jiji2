import AbstractService from "./abstract-service"

export default class VersionService extends AbstractService {

  getVersion() {
    return this.xhrManager.xhr( this.serviceUrl(""), "GET");
  }

  endpoint() {
    return "version";
  }
}
