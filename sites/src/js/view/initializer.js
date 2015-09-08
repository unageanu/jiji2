import "babel-core/polyfill";

import React        from "react";
import Router       from "react-router";
import ContainerJS  from "container-js";

import modules      from "../composing/modules";
import routes       from "./routes";

export default class Initializer {

  initialize() {
    this.createContainer();
    this.container.get("application").then(
      (application) => {
        application.initialize().then(
          (initialRoute) => this.initializeView(application, initialRoute),
          this.handleError.bind(this));
      }, this.handleError.bind(this));
  }
  createContainer() {
    this.container = new ContainerJS.Container(
      this.modules(),
      ContainerJS.PackagingPolicy.COMMON_JS_MODULE_PER_CLASS,
      ContainerJS.Loaders.COMMON_JS
    );
  }
  initializeView(application, initialRoute) {
    const location = Router.HashLocation;
    if (initialRoute) location.replace(initialRoute);
    try {
      Router.run(this.routes(), location, (Handler) => {
        const element = document.getElementById("main");
        React.render(<Handler application={application} />, element);
      });
    } catch (e) {
      this.handleError(e);
    }
  }
  handleError(error) {
    console.log(error);
    console.log(error.stack);
  }
  routes() {
    return routes;
  }
  modules() {
    return modules;
  }
}
