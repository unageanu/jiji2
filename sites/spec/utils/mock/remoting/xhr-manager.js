import XhrManager from "src/remoting/xhr-manager";
import XhrRequest from "src/remoting/xhr-request";
import Deferred   from "src/utils/deferred";

class MockXhrRequest extends XhrRequest {
  constructor(manager, url, method, body, options) {
    super(manager, url, method, body, options);
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
  resolve(result) {
    this.ajaxRequests.shift().d.resolve({data:result});
  }
  reject(error) {
    this.ajaxRequests.shift().d.reject(error);
  }
}

export default class MockXhrManager extends XhrManager {
  constructor() {
    super();
    this.requests = [];
  }
  xhr(url, method, body, options={isBackground:false}) {
    let request = new MockXhrRequest(
      this, url, method, body, options);
    this.requests.push(request);
    this.state.send(request, this);
    return request.result();
  }
  clear() {
    this.requests = [];
  }
}
