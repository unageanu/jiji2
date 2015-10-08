import AbstractService from "./abstract-service"

export default class ActionService extends AbstractService {

  post( backtestId, agentId, action ) {
    const url = this.serviceUrl( "" );
    return this.xhrManager.xhr(url, "POST", {
      backtestId:   backtestId,
      agentId:      agentId,
      action:       action
    });
  }

  endpoint() {
    return "actions";
  }
}
