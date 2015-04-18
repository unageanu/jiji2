import XhrManager from "src/remoting/xhr-manager";
import XhrRequest from "src/remoting/xhr-request";
import Deferred   from "src/utils/deferred";

class MockXhrRequest extends XhrRequest {
  constructor(manager, url, method, body, param) {
    super(manager, url, method, body, param);
    this.ajaxRequests = [];
  }
  sendRequest(settings) {
    let ajax = new Deferred();
    this.ajaxRequests.push({
      d: ajax,
      settings: settings
    });
    return ajax;
  }
}

export default class MockXhrManager extends XhrManager {
  constructor() {
    super();
    this.requests = [];
  }
  xhr(url, method, body, param) {
    let request = new MockXhrRequest(this, url, method, body, param);
    this.requests.push(request);
    this.state.send(request, this);
    return request.result();
  }
}
