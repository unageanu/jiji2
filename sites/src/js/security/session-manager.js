import ContainerJS  from "container-js";

export default class SessionManager {
  constructor() {
    this.localStorage = ContainerJS.Inject;
  }
  isLoggedIn() {
    return !!this.getToken();
  }
  setToken(token) {
    this.localStorage.set("session", {
      token : token
    });
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
  }
}
