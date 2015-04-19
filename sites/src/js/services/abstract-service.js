import ContainerJS from "container-js";

export default class AbstractService {
  constructor() {
    this.urlResolver = ContainerJS.Inject;
    this.xhrManager  = ContainerJS.Inject;
  }

  serviceUrl(path=null) {
    let url = this.urlResolver.resolveServiceUrl(this.endpoint());
    if (path) url = url + "/" + path;
    return url;
  }
}
