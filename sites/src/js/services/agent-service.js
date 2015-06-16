import AbstractService from "./abstract-service"

export default class AgentService extends AbstractService {


  getSources() {
    return this.xhrManager.xhr( this.serviceUrl("sources"), "GET");
  }
  addSource( name, memo, type="agent", body="" ) {
    return this.xhrManager.xhr( this.serviceUrl("sources"), "POST", {
      name: name,
      memo: memo,
      type: type,
      body: body
    });
  }

  getSource( id ) {
    return this.xhrManager.xhr( this.serviceUrl("sources/" + id), "GET");
  }
  updateSource( id, name, memo, body="" ) {
    return this.xhrManager.xhr( this.serviceUrl("sources/" + id), "PUT", {
      name: name,
      memo: memo,
      body: body
    });
  }
  deleteSource( id ) {
    return this.xhrManager.xhr( this.serviceUrl("sources/" + id), "DELETE");
  }

  getClasses() {
    return this.xhrManager.xhr( this.serviceUrl("classes"), "GET");
  }

  endpoint() {
    return "agents";
  }
}
