import ContainerJS   from "container-js"
import ErrorMessages from "./error-messages"

export default class ErrorHandler {

  constructor() {
    this.xhrManager = ContainerJS.Inject;
    this.eventQueue = ContainerJS.Inject;
  }

  handle(error) {
    console.log(error); // TODO
    if (error.preventDefault) return;
    const message = ErrorMessages.getMessageFor(error);
    if (message) this.eventQueue.push({type:"error", message:message});
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
