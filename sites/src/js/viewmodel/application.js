import ContainerJS  from "container-js"
import Deferred     from "../utils/deferred"

export default class Application {

  constructor() {
    this.navigator        = ContainerJS.Inject;
    this.viewModelFactory = ContainerJS.Inject;
    this.authenticator    = ContainerJS.Inject;

    this.pairs = ContainerJS.Inject;
    this.rates = ContainerJS.Inject;
  }

  initialize() {
    if ( !this.initializationDeferred ) {
      this.initializationDeferred = Deferred.when([
        this.pairs.initialize()
      ]);
    }
    return this.initializationDeferred;
  }
}
