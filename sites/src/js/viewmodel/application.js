import ContainerJS  from "container-js";

export default class Application {

  constructor() {
    this.navigator        = ContainerJS.Inject;
    this.viewModelFactory = ContainerJS.Inject;
    this.authenticator    = ContainerJS.Inject;
  }

}
