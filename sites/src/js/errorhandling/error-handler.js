import ContainerJS   from "container-js"

export default class ErrorHandler {

  constructor() {
    this.xhrManager = ContainerJS.Inject;
    this.eventQueue = ContainerJS.Inject;
  }

  handle(error) {
    if (error.preventDefault) return;
    this.eventQueue.push({type:"error", error: error});
  }

  registerHandlers() {
    this.registerNetworkErrorHandler();
    this.registerUnauthorizedErrorHandler();
  }
  registerNetworkErrorHandler() {
    this.xhrManager.addObserver("fail", (n, error) => this.handle(error));
  }
  registerUnauthorizedErrorHandler() {
    this.xhrManager.addObserver(
      "startBlocking", this.onStartBlocking.bind(this));
  }

  onStartBlocking() {
    this.eventQueue.push({type:"routing", route: "/login"});
  }
}
