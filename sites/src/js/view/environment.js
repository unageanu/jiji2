import WebEnvironment   from "./environments/web-environment"

let environment = new WebEnvironment();

export default class Environment {
  static get() {
    return environment;
  }
  static set(env) {
    environment = env;
  }
}
