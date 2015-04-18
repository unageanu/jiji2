import ContainerJS from "container-js";

export default class AbstractService {
  constructor() {
    this.urlResolver = ContainerJS.Inject;
    this.xhrManager  = ContainerJS.Inject;
  }
}
