import "babel-polyfill";

import React        from "react";
import Router       from "react-router";
import ContainerJS  from "container-js";

import modules      from "../composing/modules";
import routes       from "./routes";
import babelLoader  from "../composing/babel-loader";

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
      babelLoader
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
      this.handleError(e, application);
    }
  }
  handleError(error, application) {
    console.log(error.message);
    console.log(error.stack);
    application.googleAnalytics.sendError(error.message, true);
  }
  routes() {
    return routes;
  }
  modules() {
    return modules;
  }
}
