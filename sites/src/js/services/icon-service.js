import AbstractService from "./abstract-service"

export default class IconService extends AbstractService {

  fetch() {
    return this.xhrManager.xhr( this.serviceUrl(""), "GET");
  }

  post( backtestId, agentId, action ) {
    const url = this.serviceUrl( "" );
    return this.xhrManager.xhr(url, "POST", {
      backtestId:   backtestId,
      agentId:      agentId,
      action:       action
    });
  }

  endpoint() {
    return "icons";
  }
}
