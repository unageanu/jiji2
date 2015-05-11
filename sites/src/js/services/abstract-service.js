import ContainerJS from "container-js";

export default class AbstractService {
  constructor() {
    this.urlResolver = ContainerJS.Inject;
    this.xhrManager  = ContainerJS.Inject;
  }

  serviceUrl(path=null, params={}) {
    let base = this.endpoint();
    if (path) base = base + "/" + path;
    return this.urlResolver.resolveServiceUrl(base, params);
  }
}
