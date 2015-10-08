import ContainerJS  from "container-js";
import Observable   from "../utils/observable"

export default class SessionManager extends Observable {
  constructor() {
    super();
    this.localStorage = ContainerJS.Inject;
  }
  initialize() {
    this.updateLoginState();
  }

  setToken(token) {
    this.localStorage.set("session", {
      token : token
    });
    this.updateLoginState();
  }
  getToken() {
    const session = this.localStorage.get("session");
    if (session) {
      return session.token;
    } else {
      return null;
    }
  }
  deleteToken() {
    this.localStorage.delete("session");
    this.updateLoginState();
  }

  updateLoginState() {
    this.isLoggedIn = !!this.getToken();
  }

  set isLoggedIn(isLoggedIn) {
    this.setProperty("isLoggedIn", isLoggedIn);
  }
  get isLoggedIn() {
    return this.getProperty("isLoggedIn");
  }
}
