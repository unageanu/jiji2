import Router from "react-router";

export default class UnauthorizedExceptionHandler {

  static registerObservers(router, xhrManager) {
    xhrManager.addObserver("startBlocking", () => {
      router.transitionTo("/login");
    });
  }
}
