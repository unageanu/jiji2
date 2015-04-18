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
          this.initializeView.bind(this), this.handleError.bind(this));
  }
  createContainer() {
      this.container = new ContainerJS.Container(
          modules,
          ContainerJS.PackagingPolicy.COMMON_JS_MODULE_PER_CLASS,
          ContainerJS.Loaders.COMMON_JS
      );
  }
  initializeView(application) {
      try {
          Router.run(this.routes(), (Handler) => {
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
}
