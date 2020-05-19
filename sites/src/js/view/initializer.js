import "babel-polyfill";

import React        from "react"
import ReactDOM     from "react-dom"
import { Router, hashHistory } from 'react-router'
import ContainerJS  from "container-js"
import { IntlProvider } from "react-intl";

import modules         from "../composing/modules"
import routes          from "./routes"
import babelLoader     from "../composing/babel-loader"
import { getMessages } from "../i18n/i18n"

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
    if (initialRoute) hashHistory.replace(initialRoute);
    try {
      const element = document.getElementById("main");
      const lang = this.lang();
      ReactDOM.render(
        <IntlProvider locale={lang} messages={getMessages(lang)}>
          <Router
            history={hashHistory}
            createElement={(component, props) => {
              props.application = application;
              return React.createElement(component, props);
            }}>
            {this.routes()}
          </Router>
        </IntlProvider>, element);
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
  lang() {
    return navigator.language;
  }
}
